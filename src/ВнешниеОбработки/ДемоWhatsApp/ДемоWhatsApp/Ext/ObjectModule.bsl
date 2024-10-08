﻿
#Область СлужебныйПрограммныйИнтерфейс

// Отправляет сообщение по указанному номеру
//
// Параметры:
//  НомерТелефона - Строка - номер телефона
//  ТекстСообщения	 - Строка - текст сообщения 
// 
// Возвращаемое значение:
//   - Структура 
//
Функция ОтправитьСообщение(НомерТелефона, ТекстСообщения) Экспорт 

	СтруктураОтправки = Новый Структура;
	СтруктураОтправки.Вставить("chatId", СтрШаблон("%1@c.us", НомерТелефона));
	СтруктураОтправки.Вставить("message", ТекстСообщения);
	
	ТелоСообщения = СтруктуруJSON(СтруктураОтправки); 
	
	АдресРесурса = СтрШаблон("waInstance%1/sendMessage/%2", idInstance, apiTokenInstance);
	
	HTTPСоединение = Новый HTTPСоединение(apiUrl, , , , , , Новый ЗащищенноеСоединениеOpenSSL());
	HTTPЗапрос = Новый HTTPЗапрос(АдресРесурса); 
	HTTPЗапрос.Заголовки.Вставить("Content-Type", "application/json");
	HTTPЗапрос.УстановитьТелоИзСтроки(ТелоСообщения);

	Ответ = HTTPСоединение.ОтправитьДляОбработки(HTTPЗапрос);   
	
	Возврат Новый Структура("Успешно, ДатаОтправки", Ответ.КодСостояния = 200, ТекущаяДатаСеанса());
	
КонецФункции

// Получает следуещее сообщение из очереди на сервере
// 
// Возвращаемое значение:
//   - Структура
//
Функция ПолучитьСообщение() Экспорт 
	
	НормализованныйОтвет = Новый Структура;
	НормализованныйОтвет.Вставить("НомерТелефона");
	НормализованныйОтвет.Вставить("Дата");
	НормализованныйОтвет.Вставить("ТекстСообщения"); 

	ПолученноеСообщение = ПолучитьСообщениеИзОчереди();	
	Если Не ЗначениеЗаполнено(ПолученноеСообщение) Тогда 
		Возврат НормализованныйОтвет;
	КонецЕсли;
	
	УдалитьСообщениеИзОчереди(ПолученноеСообщение.receiptId);

	Если ПолученноеСообщение.body.typeWebhook = "incomingMessageReceived" Тогда 
		НормализованныйОтвет.НомерТелефона = СтрЗаменить(ПолученноеСообщение.body.senderData.chatId, "@c.us", ""); 
		НормализованныйОтвет.Дата = TimestampВДату(ПолученноеСообщение.body.timestamp);
		Если ПолученноеСообщение.body.messageData.typeMessage = "textMessage" Тогда 
			НормализованныйОтвет.ТекстСообщения = 
				ПолученноеСообщение.body.messageData.textMessageData.textMessage;
		КонецЕсли;
		Если ПолученноеСообщение.body.messageData.typeMessage = "extendedTextMessage" Тогда 
			НормализованныйОтвет.ТекстСообщения = 
				ПолученноеСообщение.body.messageData.extendedTextMessageData.text;
		КонецЕсли;
	КонецЕсли;
		
	
	Возврат НормализованныйОтвет;
	
КонецФункции

#КонецОбласти 

#Область СлужебныеПроцедурыИФункции

Функция ПолучитьСообщениеИзОчереди()
	
	ПолученноеСообщениеИзОчереди = Новый Структура;
	
	HTTPСоединение = Новый HTTPСоединение(apiUrl, , , , , , Новый ЗащищенноеСоединениеOpenSSL());
	АдресРесурса = СтрШаблон("waInstance%1/ReceiveNotification/%2", idInstance, apiTokenInstance);
	HTTPЗапрос = Новый HTTPЗапрос(АдресРесурса); 
	Ответ = HTTPСоединение.Получить(HTTPЗапрос);   
	Если Ответ.КодСостояния = 200 Тогда
		ТелоОтвета = Ответ.ПолучитьТелоКакСтроку();
		Если Не ПустаяСтрока(ТелоОтвета) Тогда
			ПолученноеСообщениеИзОчереди = JSONВСтруктуру(ТелоОтвета);
		КонецЕсли;
	Иначе
		ВызватьИсключение Ответ.ПолучитьТелоКакСтроку();
	КонецЕсли;
	
	Возврат ПолученноеСообщениеИзОчереди;
	
КонецФункции

Процедура УдалитьСообщениеИзОчереди(receiptId)
	
	HTTPСоединение = Новый HTTPСоединение(apiUrl, , , , , , Новый ЗащищенноеСоединениеOpenSSL());
	АдресРесурса = СтрШаблон("waInstance%1/deleteNotification/%2/%3", 
		idInstance, apiTokenInstance, Формат(receiptId, "ЧГ=0"));
	HTTPЗапрос = Новый HTTPЗапрос(АдресРесурса); 
	
	// тут, конечно, надо обработать ответ, но мы не будем этого делать сейчас
	HTTPСоединение.ВызватьHTTPМетод("DELETE", HTTPЗапрос);
	
КонецПроцедуры

Функция СтруктуруJSON(СтруктураДляПреобразования)
	
	ЗаписьJSON = Новый ЗаписьJSON();
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, СтруктураДляПреобразования);
	
	Возврат ЗаписьJSON.Закрыть();
	
КонецФункции

Функция JSONВСтруктуру(JSONДляПреобразования)
	
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку(JSONДляПреобразования);  		
	
	Возврат ПрочитатьJSON(ЧтениеJSON);
	
КонецФункции

Функция TimestampВДату(ДатаВTimestamp)  
	Попытка
		Возврат Дата("19700101030000") + ДатаВTimestamp;
	Исключение
		Возврат Неопределено;
	КонецПопытки;
КонецФункции

#КонецОбласти