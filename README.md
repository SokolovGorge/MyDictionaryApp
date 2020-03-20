# MyDictionary - англо-русский словарь с возможностью собственного наполенния.
Так же  есть режим тренировки - проверка перевода случайно выбранных слов. 
### Run Requirements

* Xcode 11
* Swift

Приложение простроено на архитетуре MVP (Model View Presenter). 
Так же реализован механизм DI (Dependency Injection) внедрения сервисов.
#### MVP Concepts
##### Presentation Logic
##### Dependency Injection
* `View`- делегирует события взаимодействия с пользователем в `Presenter` и отображает данные, переданные `Presenter`
    * Все подклассыl `UIViewController`, `UIView`, `UITableViewCell` принадлежат слою `View`
    * Обычно представление пассивно - оно не должно содержать никакой сложной логики, и поэтому в большинстве случаев нам не нужно писать модульные тесты для него
* `Presenter` - содержит логику презентации и сообщает `View`, что представить
    * Обычно один `Presenter` на каждую сцену (view controller)
    * Он не ссылается на конкретный тип `View` , а скорее ссылается на протокол "представления", который обычно реализуется подклассом `UIViewController`
    * Это должен быть простой класс и не ссылаться на какие - либо классы фреймворка `iOS`- это упрощает его повторное использование
    * `Assembly` - вводит граф объекта зависимостей в сцену (контроллер представления)
    * Для реализации концепции Dependency Injection используется фреймворк `Typhoon`
* `Router` - содержит логику навигации из одной сцены (контроллер вида) в другую
* `Assembly` - пакет компонентов собирается сборщиком, который внедряется в сторибоард контроллера и выполняет сборку на этапе awakeFromNib.    


