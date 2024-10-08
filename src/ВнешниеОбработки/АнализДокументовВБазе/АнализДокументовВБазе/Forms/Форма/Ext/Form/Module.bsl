﻿
&НаСервере
Процедура СформироватьНаСервере()
    
    ТаблицаДляЗаполнения = ДанныеПоДокументам.Выгрузить();
    РеквизитФормыВЗначение("Объект").ДанныеПоДокументамВБазеЗаПериод(
        ТаблицаДляЗаполнения, Период.ДатаНачала, Период.ДатаОкончания); 
    ДанныеПоДокументам.Загрузить(ТаблицаДляЗаполнения);
    
КонецПроцедуры

&НаКлиенте
Процедура Сформировать(Команда) 
    
    Если Не ПроверитьЗаполнение() Тогда 
        Возврат;    
    КонецЕсли;
    
    ДанныеПоДокументам.Очистить();
    СформироватьНаСервере();
    
КонецПроцедуры
