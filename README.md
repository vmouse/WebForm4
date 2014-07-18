WebForm4
========
Code generator based on the database schema and templates

Функции:

Сформировать схему для таблицы:
<pre>WFGenFields -Instance "SQLSERV01" -Database "MyTestDB" -TableName "TestTable" | ConvertTo-Json -Depth 3 | Out-File "table-schema.json"</pre>

Сгенерировать скрипт по шаблону (развернуть макровставки):
<pre>Get-Content "table-schema.json" -Raw | ConvertFrom-Json | ObjectToHash | WFMakeScript -Template C:\temp\_WebForm4\Template_AJAX.txt | Out-File "test-ajax.html"</pre>

Сгенерировать набор скриптов в соответствии с конфигурационным файлом makescript.json:
<pre>{WFMakeAllScripts -columns "table-schema.json" -target_dir "trash"</pre>

Пример конфигурационного файла makescript.json:
<pre>{
"WS": {
	"name": "ws{0}.asmx",
	"template": "Template_ASMX.txt",
	"enable": "false",
	"params": { }
	},
"AJAX": {
	"name": "{0}.html",
	"template": "Template_AJAX.txt",
	"enable": "true",
	"params": { }
	},
"PowerWebPart": {
	"name": "{0}.pwp",
	"template": "Template_PWP.txt",
	"enable": "false",
	"params": { }
	}
}</pre>

"name" 		- определяет шалон имени выходного файла, можно использовать макровставку {0}, которая заменится на имя таблицы
"template" 	- какой шаблон использовать для генерации
"enable"	- true - генерировать, false - не генировать
"params"	- дополнительные параметры, которые транслируются в шаблонное макро [param:xxxx]



<h2>Описание макро-вставок шаблонов.</h2>

<p><b>[table_name]</b> - имя таблицы</p>
<p><b>[webform_version]</b> - версия генератора кода</p>
<p><b>[param:mode]</b> - вставить параметр &quot;mode&quot; из конфигурации текущего шаблона (определяется в makescript.json для каждой таблицы)</p>
<p><b>[include:template_filepath]</b> - вставить другой шаблон (с парсингом)</p>
<p><b>&lt;CALC&gt;2^4&lt;/CALC&gt;</b> - посчитать выражение (Invoke-Expression)</p>

&lt;AL&gt;...[V]...&lt;/AL&gt; - Вертикальное выравнивание блока по меткам [V] (добить пробелами так, что бы это место было друг над другом). С табуляцией пока не дружим, превращаем в пробелы
&lt;IF FE=FieldName&gt;&lt;/IF&gt; - проверяет условие (FE = наличие заданного поля в таблице) и вставляет блок 
&lt;FL params&gt;строка_формата&lt;DL params&gt;строка_разделителя&lt;/DL&gt;&lt;/FL&gt; - формирует список полей таблицы по заданному формату. FL могут быть вложенные, соотв. сначала обрабатываются внутренние

В формат подставляются данные о текущем поле:
{0} - field name
{1} - field title (description or name if null one)
{2} - SQL data type with size/scale/precision (varchar(64))
{3} - C data type string
{4} - Nullable C data type string
{5} - Lookup Table
{6} - Lookup table key field
{7} - Field number
{8} - Referenced table primary key (for R filter)

params:

Types 		- Отобрать поля соответствующие маске типов, в которой большая буква - включить класс полей, маленькая - исключить
		&amp; - флаг для отбора на одновременное совпадение всех условий, иначе любое совпавшее минус запреты. 
		A - Все поля, кроме скрытых &quot;h&quot; и вычисляемых &quot;v&quot;
		H - Cкрытые поля (обычно те, которые не передаются в стандартных вызовах, но надо поминить что они могут возвращаться в результатах)
		P - Primary keys
		L - Lookup fields (Foreign keys)
		T - Recursive tree fields (lookup to self)
		G - Guids
		S - Text/strings fields (char, varchar, ...)
		I - Integer fields (int, bigint)
		N - Numeric fields (Money, Float, ...)
		D - Date|time fields
		B - Blob fields
		X - Binary fields (timestamp)
		F - Flags fields (fl_ ...)
		V - вычисляемые поля имен (SelectName)
		S - поля подходящие для составления SelectName
		R - поля других таблиц ссылающиеся на эту таблицу (заполнятся как обычные Lookup). не имеет смысла использовать R совместно с другими флагами
		&lt; - признак продолжения пред.списка, т.е. надо ли вставить разделитель перед первым элементом
	если не указано ни одного разрешающего фильтра (большая буква), то используются &quot;A&quot; (все поля, кроме v и h) и потом из него вычитаются указанные запреты. 
	если на одно поле срабатывает несколько фильтров или флагов, то преимущество у запретов
	скрытые типы полей нужно явно включать (H или V) для появления в списке

Like 		- Отобрать поля по похожести имени заданному шаблону
				&quot;*&quot; - все (по-умолчанию)
				&quot;*name&quot; - только те, что заканчиваются на name и т.п.



Примеры:
отобрать все поля, кроме BLOB и binary (а так же скрытых и вычисляемых, т.к. они явно не разрешены). т.к. разделителей нет, слепится все в кучу:
<pre>&lt;FL Types=&quot;bx&quot;&gt;{0}&lt;/FL&gt;</pre>

отобрать первичные ключи и любые поля с типом дата и сформировать список через запятую:
<pre>&lt;FL Types=&quot;PD&quot;&gt;{0}&lt;DL&gt;, &lt;/DL&gt;&lt;/FL&gt;</pre>

отобрать только поля-флаги с типом дата, сделать список через запятую и перенос строки:
<pre>&lt;FL Types=&quot;&amp;FD&quot;&gt;{0}&lt;DL&gt;, 
&lt;/DL&gt;&lt;/FL&gt; </pre>

отобрать поля текстового типа заканчивающиеся на name (Fullname, FirstName и т.п.)
<pre>&lt;FL Like=&quot;*name&quot; Types=&quot;S&quot;&gt;{0} &lt;/FL&gt;</pre>

сформировать список внешних ссылок в виде [локальное поле] =&gt; [таблица куда ссылаемся].[поле на которое ссылаемся]
<pre>&lt;FL Types=&quot;L&quot;&gt;{0} =&gt; {5}.{6}&lt;/FL&gt;</pre>

сформировать список ссылок на эту таблицу из других
<pre>&lt;FL Types=&quot;R&quot;&gt;
	Обнаружена внешняя ссылка: {5}.{6} -&gt; [table_name].{0})
&lt;/FL&gt; </pre>

