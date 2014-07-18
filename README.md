  <style type="text/css">
td.linenos { background-color: #f0f0f0; padding-right: 10px; }
span.lineno { background-color: #f0f0f0; padding: 0 5px 0 5px; }
pre { line-height: 125%; }
body .hll { background-color: #ffffcc }
body  { background: #f8f8f8; }
body .c { color: #408080; font-style: italic } /* Comment */
body .err { border: 1px solid #FF0000 } /* Error */
body .k { color: #008000; font-weight: bold } /* Keyword */
body .o { color: #666666 } /* Operator */
body .cm { color: #408080; font-style: italic } /* Comment.Multiline */
body .cp { color: #BC7A00 } /* Comment.Preproc */
body .c1 { color: #408080; font-style: italic } /* Comment.Single */
body .cs { color: #408080; font-style: italic } /* Comment.Special */
body .gd { color: #A00000 } /* Generic.Deleted */
body .ge { font-style: italic } /* Generic.Emph */
body .gr { color: #FF0000 } /* Generic.Error */
body .gh { color: #000080; font-weight: bold } /* Generic.Heading */
body .gi { color: #00A000 } /* Generic.Inserted */
body .go { color: #888888 } /* Generic.Output */
body .gp { color: #000080; font-weight: bold } /* Generic.Prompt */
body .gs { font-weight: bold } /* Generic.Strong */
body .gu { color: #800080; font-weight: bold } /* Generic.Subheading */
body .gt { color: #0044DD } /* Generic.Traceback */
body .kc { color: #008000; font-weight: bold } /* Keyword.Constant */
body .kd { color: #008000; font-weight: bold } /* Keyword.Declaration */
body .kn { color: #008000; font-weight: bold } /* Keyword.Namespace */
body .kp { color: #008000 } /* Keyword.Pseudo */
body .kr { color: #008000; font-weight: bold } /* Keyword.Reserved */
body .kt { color: #B00040 } /* Keyword.Type */
body .m { color: #666666 } /* Literal.Number */
body .s { color: #BA2121 } /* Literal.String */
body .na { color: #7D9029 } /* Name.Attribute */
body .nb { color: #008000 } /* Name.Builtin */
body .nc { color: #0000FF; font-weight: bold } /* Name.Class */
body .no { color: #880000 } /* Name.Constant */
body .nd { color: #AA22FF } /* Name.Decorator */
body .ni { color: #999999; font-weight: bold } /* Name.Entity */
body .ne { color: #D2413A; font-weight: bold } /* Name.Exception */
body .nf { color: #0000FF } /* Name.Function */
body .nl { color: #A0A000 } /* Name.Label */
body .nn { color: #0000FF; font-weight: bold } /* Name.Namespace */
body .nt { color: #008000; font-weight: bold } /* Name.Tag */
body .nv { color: #19177C } /* Name.Variable */
body .ow { color: #AA22FF; font-weight: bold } /* Operator.Word */
body .w { color: #bbbbbb } /* Text.Whitespace */
body .mf { color: #666666 } /* Literal.Number.Float */
body .mh { color: #666666 } /* Literal.Number.Hex */
body .mi { color: #666666 } /* Literal.Number.Integer */
body .mo { color: #666666 } /* Literal.Number.Oct */
body .sb { color: #BA2121 } /* Literal.String.Backtick */
body .sc { color: #BA2121 } /* Literal.String.Char */
body .sd { color: #BA2121; font-style: italic } /* Literal.String.Doc */
body .s2 { color: #BA2121 } /* Literal.String.Double */
body .se { color: #BB6622; font-weight: bold } /* Literal.String.Escape */
body .sh { color: #BA2121 } /* Literal.String.Heredoc */
body .si { color: #BB6688; font-weight: bold } /* Literal.String.Interpol */
body .sx { color: #008000 } /* Literal.String.Other */
body .sr { color: #BB6688 } /* Literal.String.Regex */
body .s1 { color: #BA2121 } /* Literal.String.Single */
body .ss { color: #19177C } /* Literal.String.Symbol */
body .bp { color: #008000 } /* Name.Builtin.Pseudo */
body .vc { color: #19177C } /* Name.Variable.Class */
body .vg { color: #19177C } /* Name.Variable.Global */
body .vi { color: #19177C } /* Name.Variable.Instance */
body .il { color: #666666 } /* Literal.Number.Integer.Long */

  </style>
  WebForm4
========
Code generator based on the database schema and templates

<div class="highlight" style="background: #f8f8f8"><pre style="line-height: 125%">Описание макро-вставок шаблонов.

[table_name] - имя таблицы
[webform_version] - версия генератора кода
[param:mode] - вставить параметр &quot;mode&quot; из конфигурации текущего шаблона (определяется в makescript.json для каждой таблицы)
[include:template_filepath] - вставить другой шаблон (с парсингом)
&lt;CALC&gt;2^4&lt;/CALC&gt; - посчитать выражение (Invoke-Expression)

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
&lt;FL Types=&quot;bx&quot;&gt;{0}&lt;/FL&gt;

отобрать первичные ключи и любые поля с типом дата и сформировать список через запятую:
&lt;FL Types=&quot;PD&quot;&gt;{0}&lt;DL&gt;, &lt;/DL&gt;&lt;/FL&gt;

отобрать только поля-флаги с типом дата, сделать список через запятую и перенос строки:
&lt;FL Types=&quot;&amp;FD&quot;&gt;{0}&lt;DL&gt;, 
&lt;/DL&gt;&lt;/FL&gt; 

отобрать поля текстового типа заканчивающиеся на name (Fullname, FirstName и т.п.)
&lt;FL Like=&quot;*name&quot; Types=&quot;S&quot;&gt;{0} &lt;/FL&gt;

сформировать список внешних ссылок в виде [локальное поле] =&gt; [таблица куда ссылаемся].[поле на которое ссылаемся]
&lt;FL Types=&quot;L&quot;&gt;{0} =&gt; {5}.{6}&lt;/FL&gt;

сформировать список ссылок на эту таблицу из других
&lt;FL Types=&quot;R&quot;&gt;
	Обнаружена внешняя ссылка: {5}.{6} -&gt; [table_name].{0})
&lt;/FL&gt; 
</pre></div>
