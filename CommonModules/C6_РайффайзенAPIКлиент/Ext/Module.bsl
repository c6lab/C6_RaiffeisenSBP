// (c) 2021 C6 Lab, Ramona Orlova, http://c6lab.org
// Все права сохранены.
////////////////////////////////////////////////////////////////////////////////

//
Функция ДатаВСтроку(Значение) Экспорт
	//2020-01-31T09:14:38.107227+03:00
	Возврат Формат(Значение, "ДФ=yyyy-MM-dd") + "T" + Формат(Значение, "ДФ=HH:mm:ss") + ".000000+03:00";
КонецФункции

//
Функция СтрокаВДату(Значение) Экспорт
	Возврат ?(НЕ ПустаяСтрока(Значение),
		Дата(
			СтрЗаменить(
				СтрЗаменить(
					СтрЗаменить(Лев(Значение, 19), "T", ""),
				"-", ""),
			":", "")
		),
	'00010101');
КонецФункции

// РегистрацияQRКода v1
//
// Параметры
//   НомерЗаказа
//   Сумма
//   НазначениеПлатежа
//   ДопИнфо
//   СрокДействия
// Результат
//   ИдКода
//   СсылкаОплаты
//   СсылкаИзображения
Функция РегистрацияQRКода(Параметры, Результат) Экспорт
	Перем Рез;
	Перем НастройкиAPI;
	Перем HTTPСоединение, ЗаголовкиHTTP, HTTPЗапрос, HTTPОтвет;
	Перем JSONСтруктура, ЗаписьJSON, ЧтениеJSON;
	
	Рез = Ложь;
	Результат = Новый Структура;
	
	НастройкиAPI = C6_СБПВызовСервера.ПолучитьНастройки(Параметры);
	
	ЗаголовкиHTTP = Новый Соответствие;
	ЗаголовкиHTTP.Вставить("Content-Type", "application/json");
	//ЗаголовкиHTTP.Вставить("Authorization", "Bearer " + НастройкиAPI.Токен);
	JSONСтруктура = Новый Структура;
	JSONСтруктура.Вставить("account", НастройкиAPI.РасчСчет);
	JSONСтруктура.Вставить("additionalInfo", СокрЛП(Параметры.ДопИнфо));
	JSONСтруктура.Вставить("amount", Формат(Параметры.Сумма, "ЧГ=0"));
	JSONСтруктура.Вставить("currency", "RUB");
	JSONСтруктура.Вставить("order", Параметры.НомерЗаказа);
	JSONСтруктура.Вставить("paymentDetails", СокрЛП(Параметры.НазначениеПлатежа));
	JSONСтруктура.Вставить("qrType", "QRDynamic");
	JSONСтруктура.Вставить("qrExpirationDate", ДатаВСтроку(Параметры.СрокДействия));
	JSONСтруктура.Вставить("sbpMerchantId", НастройкиAPI.МерчантИд);
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, JSONСтруктура);
	
	HTTPЗапрос = Новый HTTPЗапрос("/api/sbp/v1/qr/register", ЗаголовкиHTTP);
	HTTPЗапрос.УстановитьТелоИзСтроки(ЗаписьJSON.Закрыть());
	HTTPСоединение = Новый HTTPСоединение(НастройкиAPI.Хост, Неопределено, Неопределено, Неопределено, Неопределено, 120, Новый ЗащищенноеСоединениеOpenSSL);
	HTTPОтвет = HTTPСоединение.ВызватьHTTPМетод("POST", HTTPЗапрос);
	
	Если ((HTTPОтвет.КодСостояния = 200) или (HTTPОтвет.КодСостояния = 201)) Тогда
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(HTTPОтвет.ПолучитьТелоКакСтроку());
		JSONСтруктура = ПрочитатьJSON(ЧтениеJSON);
		Если (JSONСтруктура.Свойство("code")) Тогда
			Если (JSONСтруктура.code = "SUCCESS") Тогда
				Результат.Вставить("КодОплаты", JSONСтруктура.qrId);
				Результат.Вставить("URLКодаОплаты", JSONСтруктура.payload);
				Результат.Вставить("URLИзображенияКода", JSONСтруктура.qrUrl);
				Рез = Истина;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Рез;
КонецФункции

// ОтменаQRКода v2
Функция ОтменаQRКода(Параметры, Результат) Экспорт
	Перем Рез;
	Рез = Ложь;
	// to do
	Возврат Рез;
КонецФункции

// ИнформацияПоQRКоду v1 (deprecated)
//
// Параметры
//   ИдКода
// Результат
//   ИдКода
//   СсылкаОплаты
//   СсылкаИзображения
Функция ИнформацияПоQRКодуV1(Параметры, Результат) Экспорт
	Перем Рез;
	Перем НастройкиAPI;
	Перем HTTPСоединение, ЗаголовкиHTTP, HTTPЗапрос, HTTPОтвет;
	Перем JSONСтруктура, ЗаписьJSON, ЧтениеJSON;
	
	Рез = Ложь;
	Результат = Новый Структура;
	
	НастройкиAPI = C6_СБПВызовСервера.ПолучитьНастройки(Параметры);
	
	ЗаголовкиHTTP = Новый Соответствие;
	ЗаголовкиHTTP.Вставить("Content-Type", "application/json");
	ЗаголовкиHTTP.Вставить("Authorization", "Bearer " + НастройкиAPI.Токен);
	//JSONСтруктура = Новый Структура;
	//JSONСтруктура.Вставить("qrId", Параметры.КодОплаты);
	//ЗаписьJSON = Новый ЗаписьJSON;
	//ЗаписьJSON.УстановитьСтроку();
	//ЗаписатьJSON(ЗаписьJSON, JSONСтруктура);
	
	HTTPЗапрос = Новый HTTPЗапрос("/api/sbp/v1/qr/" + Параметры.КодОплаты + "/info", ЗаголовкиHTTP);
	//HTTPЗапрос.УстановитьТелоИзСтроки(ЗаписьJSON.Закрыть());
	HTTPСоединение = Новый HTTPСоединение(НастройкиAPI.Хост, Неопределено, Неопределено, Неопределено, Неопределено, 120, Новый ЗащищенноеСоединениеOpenSSL);
	HTTPОтвет = HTTPСоединение.ВызватьHTTPМетод("GET", HTTPЗапрос);
	
	Если ((HTTPОтвет.КодСостояния = 200) или (HTTPОтвет.КодСостояния = 201)) Тогда
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(HTTPОтвет.ПолучитьТелоКакСтроку());
		JSONСтруктура = ПрочитатьJSON(ЧтениеJSON);
		Если (JSONСтруктура.Свойство("code")) Тогда
			Если (JSONСтруктура.code = "SUCCESS") Тогда
				Результат.Вставить("КодОплаты", JSONСтруктура.qrId);
				Результат.Вставить("URLКодаОплаты", JSONСтруктура.payload);
				Результат.Вставить("URLИзображенияКода", JSONСтруктура.qrUrl);
				Рез = Истина;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Рез;
КонецФункции

// ИнформацияПоQRКоду v2
//
// Параметры
//   ИдКода
// Результат
//   ИдКода
//   СсылкаОплаты
//   СсылкаИзображения
//   СтатусКода*
//   СрокДействия*
Функция ИнформацияПоQRКоду(Параметры, Результат) Экспорт
	// to do
	Возврат ИнформацияПоQRКодуV1(Параметры, Результат);
КонецФункции

// ИнформацияПоПлатежу v1
//
// Параметры
//   ИдКода
// Результат
Функция ИнформацияПоПлатежу(Параметры, Результат) Экспорт
	Перем Рез;
	Перем НастройкиAPI;
	Перем HTTPСоединение, ЗаголовкиHTTP, HTTPЗапрос, HTTPОтвет;
	Перем JSONСтруктура, ЗаписьJSON, ЧтениеJSON;
	
	Рез = Ложь;
	Результат = Новый Структура;
	
	НастройкиAPI = C6_СБПВызовСервера.ПолучитьНастройки(Параметры);
	
	ЗаголовкиHTTP = Новый Соответствие;
	ЗаголовкиHTTP.Вставить("Content-Type", "application/json");
	ЗаголовкиHTTP.Вставить("Authorization", "Bearer " + НастройкиAPI.Токен);
	//JSONСтруктура = Новый Структура;
	//JSONСтруктура.Вставить("qrId", Параметры.КодОплаты);
	//ЗаписьJSON = Новый ЗаписьJSON;
	//ЗаписьJSON.УстановитьСтроку();
	//ЗаписатьJSON(ЗаписьJSON, JSONСтруктура);
	
	HTTPЗапрос = Новый HTTPЗапрос("/api/sbp/v1/qr/" + Параметры.КодОплаты + "/payment-info", ЗаголовкиHTTP);
	//HTTPЗапрос.УстановитьТелоИзСтроки(ЗаписьJSON.Закрыть());
	HTTPСоединение = Новый HTTPСоединение(НастройкиAPI.Хост, Неопределено, Неопределено, Неопределено, Неопределено, 120, Новый ЗащищенноеСоединениеOpenSSL);
	HTTPОтвет = HTTPСоединение.ВызватьHTTPМетод("GET", HTTPЗапрос);
	
	Если ((HTTPОтвет.КодСостояния = 200) или (HTTPОтвет.КодСостояния = 201)) Тогда
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(HTTPОтвет.ПолучитьТелоКакСтроку());
		JSONСтруктура = ПрочитатьJSON(ЧтениеJSON);
		Если (JSONСтруктура.Свойство("code")) Тогда
			Если (JSONСтруктура.code = "SUCCESS") Тогда
				//Результат.Вставить("ДопИнфо", JSONСтруктура.additionalInfo);
				//Результат.Вставить("НазначениеПлатежа", JSONСтруктура.paymentPurpose);
				Результат.Вставить("Сумма", Число(JSONСтруктура.amount));
				Результат.Вставить("ВремяСоздания", JSONСтруктура.createDate);
				//Результат.Вставить("Валюта", JSONСтруктура.currency);
				//Результат.Вставить("ИдПартнера", JSONСтруктура.merchantId);
				Результат.Вставить("НомерЗаказа", JSONСтруктура.order);
				Результат.Вставить("СтатусКодаОплаты", JSONСтруктура.paymentStatus);
				Результат.Вставить("КодОплаты", JSONСтруктура.qrId);
				Результат.Вставить("МерчантИд", JSONСтруктура.sbpMerchantId);
				// на текущий момент (не оплачено) этого поля нету в ответе
				Результат.Вставить("ВремяТранзакции", ?(JSONСтруктура.Свойство("transactionDate"), JSONСтруктура.transactionDate, ""));
				Результат.Вставить("ИдТранзакции", JSONСтруктура.transactionId);
				//Результат.Вставить("СрокДействия", JSONСтруктура.qrExpirationDate);
				Рез = Истина;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Рез;
КонецФункции

// РегистрацияВозвратаПоПлатежу v1
Функция РегистрацияВозвратаПоПлатежу(Параметры, Результат) Экспорт
	Перем Рез;
	Перем НастройкиAPI;
	Перем HTTPСоединение, ЗаголовкиHTTP, HTTPЗапрос, HTTPОтвет;
	Перем JSONСтруктура, ЗаписьJSON, ЧтениеJSON;
	
	Рез = Ложь;
	Результат = Новый Структура;
	
	НастройкиAPI = C6_СБПВызовСервера.ПолучитьНастройки(Параметры);
	
	ЗаголовкиHTTP = Новый Соответствие;
	ЗаголовкиHTTP.Вставить("Content-Type", "application/json");
	ЗаголовкиHTTP.Вставить("Authorization", "Bearer " + НастройкиAPI.Токен);
	JSONСтруктура = Новый Структура;
	JSONСтруктура.Вставить("amount", Формат(Параметры.Сумма, "ЧГ=0"));
	JSONСтруктура.Вставить("order", Параметры.НомерЗаказа);
	JSONСтруктура.Вставить("paymentDetails", СокрЛП(Параметры.НазначениеПлатежа));
	JSONСтруктура.Вставить("refundId", Параметры.НомерВозврата);
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, JSONСтруктура);
	
	HTTPЗапрос = Новый HTTPЗапрос("/api/sbp/v1/refund", ЗаголовкиHTTP);
	HTTPЗапрос.УстановитьТелоИзСтроки(ЗаписьJSON.Закрыть());
	HTTPСоединение = Новый HTTPСоединение(НастройкиAPI.Хост, Неопределено, Неопределено, Неопределено, Неопределено, 120, Новый ЗащищенноеСоединениеOpenSSL);
	HTTPОтвет = HTTPСоединение.ВызватьHTTPМетод("POST", HTTPЗапрос);
	
	Если ((HTTPОтвет.КодСостояния = 200) или (HTTPОтвет.КодСостояния = 201)) Тогда
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(HTTPОтвет.ПолучитьТелоКакСтроку());
		JSONСтруктура = ПрочитатьJSON(ЧтениеJSON);
		Если (JSONСтруктура.Свойство("code")) Тогда
			Если (JSONСтруктура.code = "SUCCESS") Тогда
				Результат.Вставить("Сумма", JSONСтруктура.amount);
				Результат.Вставить("СтатусВозврата", JSONСтруктура.refundStatus);
				Рез = Истина;
			Иначе
				Сообщить(JSONСтруктура.message);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Рез;
КонецФункции

// ИнформацияПоВозвратуПлатежа v1
Функция ИнформацияПоВозвратуПлатежа(Параметры, Результат) Экспорт
	Перем Рез;
	Перем НастройкиAPI;
	Перем HTTPСоединение, ЗаголовкиHTTP, HTTPЗапрос, HTTPОтвет;
	Перем JSONСтруктура, ЗаписьJSON, ЧтениеJSON;
	
	Рез = Ложь;
	Результат = Новый Структура;
	
	НастройкиAPI = C6_СБПВызовСервера.ПолучитьНастройки(Параметры);
	
	ЗаголовкиHTTP = Новый Соответствие;
	ЗаголовкиHTTP.Вставить("Content-Type", "application/json");
	ЗаголовкиHTTP.Вставить("Authorization", "Bearer " + НастройкиAPI.Токен);
	//JSONСтруктура = Новый Структура;
	//JSONСтруктура.Вставить("qrId", Параметры.КодОплаты);
	//ЗаписьJSON = Новый ЗаписьJSON;
	//ЗаписьJSON.УстановитьСтроку();
	//ЗаписатьJSON(ЗаписьJSON, JSONСтруктура);
	
	HTTPЗапрос = Новый HTTPЗапрос("/api/sbp/v1/refund/" + Параметры.НомерВозврата, ЗаголовкиHTTP);
	//HTTPЗапрос.УстановитьТелоИзСтроки(ЗаписьJSON.Закрыть());
	HTTPСоединение = Новый HTTPСоединение(НастройкиAPI.Хост, Неопределено, Неопределено, Неопределено, Неопределено, 120, Новый ЗащищенноеСоединениеOpenSSL);
	HTTPОтвет = HTTPСоединение.ВызватьHTTPМетод("GET", HTTPЗапрос);
	
	Если ((HTTPОтвет.КодСостояния = 200) или (HTTPОтвет.КодСостояния = 201)) Тогда
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(HTTPОтвет.ПолучитьТелоКакСтроку());
		JSONСтруктура = ПрочитатьJSON(ЧтениеJSON);
		Если (JSONСтруктура.Свойство("code")) Тогда
			Если (JSONСтруктура.code = "SUCCESS") Тогда
				Результат.Вставить("Сумма", JSONСтруктура.amount);
				Результат.Вставить("СтатусВозврата", JSONСтруктура.refundStatus);
				Рез = Истина;
			Иначе
				Сообщить(JSONСтруктура.message);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Рез;
КонецФункции
