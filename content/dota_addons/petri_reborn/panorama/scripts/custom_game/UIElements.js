"use strict";

var __DEBUG__ = true;

/*
        Вспомогательные функции
*/

// Для отладки
function Msg()
{
    if (__DEBUG__)
    {
        var str = "";
        for (var a in arguments)
            str += arguments[a];
        $.Msg(str);
    }
}

function ShowChilds( element, level)
{
    if (level > 10)
        return;

    var padding = "";
    for (var i = 0; i < level; i++)
        padding += "  ";

    Msg( padding + element);
    for(var m in element)
        if (m != "Parent" && m != "Root")
            if (element[m] instanceof UIElement)
                ShowChilds( element[m], level + 1);
}


/*
        Класс UIElement
*/

UIElement.prototype.ShowUITree = function()
{
    ShowChilds( this, 0 )
}

UIElement.prototype.toString = function()
{
    return this.Name;
}

UIElement.prototype.UpdateChildsList = function()
{
    this.Childs = {};
    if ( !this.Element )
        return;

    var childCount = this.Element.GetChildCount();


    for (var i = 0; i < childCount; i++) {
        var child = this.Element.GetChild(i);
        var name = child.id;
        
        if (name)
        {
            this[name] = new UIElement( name, this, this.Root == null ? this : this.Root );
        }
    };
}

function UIElement( name, parent, root )
{
    this.Root = root;
    this.Parent = parent;
    this.Name = name;

    // Определяем ссылку на реальный элемент
    this.Element = parent == null ? $( "#" + name ) : parent.Element.FindChild( name );

    // Функция загрузки элементов объявлена в самом элементе
    this.LoadLayout = $.GetContextPanel().data()["LoadLayout" + name];
    Msg(this.LoadLayout)

    this.Update = function () {
        if ($.GetContextPanel().data["Update" + name])
            return $.GetContextPanel().data["Update" + name];
        return function() { };
    }
    
    // Если функция найдена, то подгружаем разметку
    if (this.LoadLayout)
        this.LoadLayout();
        
    this.UpdateChildsList();
}