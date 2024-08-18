﻿
#Область ОписаниеПеременных

&НаКлиенте
Перем СписокЧатов;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаКлиенте
Асинх Процедура ПриОткрытии(Отказ)
	
	Объект.apiUrl = "1103.api.green-api.com";;
	
	СписокЧатов = Новый Соответствие;
	Объект.idInstance = Ждать ВвестиСтрокуАсинх("", "Введите idInstance");
	Если Не ЗначениеЗаполнено(Объект.idInstance) Тогда 
		ВызватьИсключение "Заполните idInstance";
	КонецЕсли; 
	
	Объект.apiTokenInstance = Ждать ВвестиСтрокуАсинх("", "Введите apiTokenInstance");
	Если Не ЗначениеЗаполнено(Объект.apiTokenInstance) Тогда 
		ВызватьИсключение "Заполните apiTokenInstance";
	КонецЕсли; 
	
	
КонецПроцедуры
 
#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыНомера

&НаКлиенте
Процедура НомераПриАктивизацииСтроки(Элемент)
	
	ТекущаяСтрока = Элементы.Номера.ТекущиеДанные;
	Если ТекущаяСтрока = Неопределено Тогда 
		Возврат;
	КонецЕсли; 

	ЗаполнитьИсторияПерепискиПоТекущемуЧату(ТекущаяСтрока.Значение);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Асинх Процедура ДобавитьНовыйЧат(Команда)
	
	ВведенныйНомер = Ждать ВвестиЧислоАсинх("", "Введите номер телефона получателя в формате 79991234567");
	
	НомерТелефона = Формат(ВведенныйНомер, "ЧГ=0");
	Если СписокЧатов.Получить(НомерТелефона) <> Неопределено Тогда 
		ПоказатьПредупреждение(, "Чат с таким номером создан ранее");
		Возврат;
	КонецЕсли; 
	
	Номера.Добавить(НомерТелефона);
	СписокЧатов.Вставить(НомерТелефона, Новый Массив);
	
КонецПроцедуры

&НаКлиенте
Процедура ОтправитьСообщение(Команда)
	
	ТекущаяСтрока = Элементы.Номера.ТекущиеДанные;
	Если ТекущаяСтрока = Неопределено Тогда 
		ПоказатьПредупреждение(, "Не выбран номер отправки");
		Возврат;
	КонецЕсли; 
	РезультатОтправки = ОтправитьСообщениеНаСервере(ТекущаяСтрока.Значение, ТекстСообщения); 
	Если РезультатОтправки.Успешно Тогда
		СообщенияИзЧата = СписокЧатов.Получить(ТекущаяСтрока.Значение);
		ДанныеСообщения = ДанныеСообщенияКДобавлению(РезультатОтправки.ДатаОтправки, Истина, ТекстСообщения);
		СообщенияИзЧата.Добавить(ДанныеСообщения); 	
		ДобавитьСтрокуИсторииПерепискиПоТекущемуЧату(ДанныеСообщения);
		ТекстСообщения = "";
	КонецЕсли;
	
КонецПроцедуры
 
&НаКлиенте
Процедура ПолучитьСообщение(Команда)

	ПолученныеСообщения = ПолучитьСообщениеНаСервере();
	Если Не ЗначениеЗаполнено(ПолученныеСообщения.НомерТелефона) Тогда 
		Сообщить("Новых сообщений не получено");
		Возврат;	
	КонецЕсли;
	
	СообщенияИзЧата = СписокЧатов.Получить(ПолученныеСообщения.НомерТелефона);
	Если СообщенияИзЧата = Неопределено Тогда
		Сообщение = СтрШаблон("Получено сообщение '%1' по номеру '%2', которого нет в списке контактов",
			ПолученныеСообщения.ТекстСообщения, ПолученныеСообщения.НомерТелефона);
		Сообщить("Новых сообщений не получено");
		Возврат;	
	КонецЕсли;
	
	ДанныеСообщения = ДанныеСообщенияКДобавлению(ПолученныеСообщения.Дата, Ложь, ПолученныеСообщения.ТекстСообщения);
	СообщенияИзЧата.Добавить(ДанныеСообщения);

	ТекущаяСтрока = Элементы.Номера.ТекущиеДанные;
	Если ТекущаяСтрока <> Неопределено И ТекущаяСтрока.Значение = ПолученныеСообщения.НомерТелефона Тогда 
		ДобавитьСтрокуИсторииПерепискиПоТекущемуЧату(ДанныеСообщения);
	КонецЕсли; 	
	Сообщить("Получено новое сообщение по номеру " + ПолученныеСообщения.НомерТелефона);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции


&НаКлиенте
Функция ДанныеСообщенияКДобавлению(ДатаСообщения, Исходящее, ТекстСообщения)
	
	ДанныеСообщения = Новый Структура;
	ДанныеСообщения.Вставить("Дата", ДатаСообщения);
	ДанныеСообщения.Вставить("Исходящее", Исходящее);
	ДанныеСообщения.Вставить("ТекстСообщения", ТекстСообщения);
	
	Возврат ДанныеСообщения;
	
КонецФункции

&НаКлиенте
Процедура ЗаполнитьИсторияПерепискиПоТекущемуЧату(НомерТелефона)
	
	ИсторияПерепискиПоТекущемуЧату.Очистить();

	СообщенияИзЧата = СписокЧатов.Получить(НомерТелефона);
	Для Каждого СообщениеИзЧата Из СообщенияИзЧата Цикл 
		ДобавитьСтрокуИсторииПерепискиПоТекущемуЧату(СообщениеИзЧата);
	КонецЦикла;
	
КонецПроцедуры 

&НаКлиенте
Процедура ДобавитьСтрокуИсторииПерепискиПоТекущемуЧату(ДанныеСообщения)
	
	ПервыйСимвол = "";
	Если ДанныеСообщения.Исходящее Тогда 
		ПервыйСимвол = Символы.ВТаб;
	КонецЕсли;
	СтрокаДляДобавления = СтрШаблон("(%1) %2", ДанныеСообщения.Дата, ДанныеСообщения.ТекстСообщения); 
	ИсторияПерепискиПоТекущемуЧату.ДобавитьСтроку(СтрокаДляДобавления);
	
КонецПроцедуры 

&НаСервере
Функция ОтправитьСообщениеНаСервере(НомерТелефона, ТекстСообщения)
	Возврат РеквизитФормыВЗначение("Объект").ОтправитьСообщение(НомерТелефона, ТекстСообщения);	
КонецФункции

&НаСервере
Функция ПолучитьСообщениеНаСервере()
	Возврат РеквизитФормыВЗначение("Объект").ПолучитьСообщение();	
КонецФункции

#КонецОбласти


