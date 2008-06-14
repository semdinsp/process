/*
 *  OpenWFEru densha - open source ruby workflow and bpm engine
 *  (c) 2007 John Mettraux
 *
 *  OpenWFEru densha is freely distributable under the terms 
 *  of a BSD-style license.
 *  For details, see the OpenWFEru web site: http://openwferu.rubyforge.org
 *
 *  Made in Japan
 */

var idcounter = 0;

function nextId () {

    var id = "f__"+idcounter;
    idcounter += 1;

    return id;
}

function omover (id, dom_class) {

    return "$('"+id+"').addClassName('"+dom_class+"');";
}

function omout (id, dom_class) {

    return "$('"+id+"').removeClassName('"+dom_class+"');";
}

function removeWorkitemRow (buttonId) {

    var button = $(buttonId);
    button.parentNode.parentNode.remove();
}

function createWorkitemRow (parent) {

    var id = nextId();
    
    var elt = document.createElement('div');
    parent.appendChild(elt);
    
    elt.setAttribute('class', "workitem_row");
    elt.setAttribute('id', id);
    
    elt.setAttribute('onmouseover', omover(id, 'workitem_row_over'));
    elt.setAttribute('onmouseout', omout(id, 'workitem_row_over'));

    return elt;
}

function renderAddFieldButton (parent) {

    var eRow = document.createElement('div');
    parent.appendChild(eRow);

    var id = nextId();
    eRow.setAttribute('id', id);

    eRow.setAttribute('class', "workitem_row_additem");

    var eKey = document.createElement('div');
    eRow.appendChild(eKey);
    eKey.setAttribute('class', "workitem_row_key");

    eKey.innerHTML = 
        //'<a href="#" onclick="addField(\''+id+'\');">+</a>';
        '<span '+
        'class="stealth_click" '+
        'onclick="addField(\''+id+'\');" '+
        'title="adds an entry"'+
        '>+</span>';

    var eValue = document.createElement('div');
    eRow.appendChild(eValue);
    eValue.setAttribute('class', "workitem_row_value");

    // clearing

    var eClear = document.createElement('div');
    eRow.appendChild(eClear);
    eClear.setAttribute('style', 'clear: both;');
}

function addField (addItemElt, rw) {

    eAddItem = $(addItemElt);

    var parent = eAddItem.parentNode;

    eAddItem.remove();

    newField(parent, NoTypeField, true);

    renderAddFieldButton(parent);
}


//
// FIELD CLASSES

var Field = Class.create({

    initialize : function (parent, rw) {

        //console.debug("rw : "+rw);

        this.parent = $(parent);
        this.parent.owfeField = this;

        this.rw = rw;
    },

    parentClass : function () {

        return this.parent.getAttribute("class");
    },

    findChildFieldWithClass : function (class_name) {

        var children = this.parent.immediateDescendants();

        for (var i=0; i < children.length; i++) {

            var child = children[i];

            if (child.getAttribute("class") == class_name) {
                return child.owfeField;
            }
        }
        return null;
    }
});


var NoTypeField = Class.create(Field, {

    initialize : function ($super, parent, value, rw) {

        $super(parent, rw);

        this.elementId = nextId();

        this.element = document.createElement("div");
        this.element.setAttribute("id", this.elementId);
        this.element.setAttribute("class", "workitem_no_type_field");
        this.parent.appendChild(this.element);

        this.addType('string', "''");

        if (this.parentClass() != "workitem_row_key") {
            this.addSpace();
            this.addType('hash', "{}");
        }
    },

    addSpace : function () {

        this.element.appendChild(document.createTextNode(" "));
    },

    addType : function (type_name, initial_value) {

        var elt = document.createElement("a");
        this.element.appendChild(elt);
        elt.setAttribute(
            "href", 
            "#");
        elt.setAttribute(
            "onclick", 
            "replaceField('"+this.elementId+"', "+initial_value+", "+this.rw+");");

        var txt = document.createTextNode(type_name);
        elt.appendChild(txt);
    },

    getValue : function () {

        return "_undefined_";
    }
});


var StringField = Class.create(Field, {

    initialize : function ($super, parent, value, rw) {

        $super(parent, rw);

        this.render(value);
    },

    render : function (value) {

        if (this.rw) {

            this.element = document.createElement("input");
            this.element.setAttribute("type", "text");
            this.element.setAttribute("class", "workitem_string_input");
            this.element.setAttribute("value", value.toString());

            if (this.parent.getAttribute("class") == "workitem_row_key") {
                this.element.setAttribute("style", "text-align: right");
            }

            this.parent.appendChild(this.element);
        }
        else {

            this.element = document.createTextNode(value);

            this.parent.appendChild(this.element);
        }
    },

    getValue : function () {

        if (this.rw) return this.element.value.strip();

        return new String(this.element.nodeValue);
    }
});


var NumberField = Class.create(StringField, {

    getValue : function ($super) {

        return new Number($super());
    }
});


var BooleanField = Class.create(StringField, {

    getValue : function ($super) {

        return ($super() == "true");
    }
});


var HashEntryField = Class.create(Field, {

    initialize : function ($super, parent, key, value, rw) {

        $super(parent, rw);

        //
        // key
        
        var eKey = document.createElement('div');
        this.parent.appendChild(eKey);
        eKey.setAttribute('class', "workitem_row_key");

        if (this.rw) {

            var eMinus = document.createElement('span');
            eKey.appendChild(eMinus);

            var eMinusId = nextId();

            eMinus.setAttribute("id", eMinusId);
            eMinus.setAttribute("class", "stealth_click workitem_minus_button");
            eMinus.setAttribute("title", "removes this entry");

            eMinus.setAttribute("onclick", "removeWorkitemRow('"+eMinusId+"')");

            eMinus.appendChild(document.createTextNode("-"));
        }

        newField(eKey, key, rw);

        //
        // value

        var eValue = document.createElement('div');
        this.parent.appendChild(eValue);
        eValue.setAttribute('class', "workitem_row_value");
        newField(eValue, value, rw);

        // clearing

        var eClear = document.createElement('div');
        eClear.setAttribute('style', 'clear: both;');
        this.parent.appendChild(eClear);
    },

    getValue : function () {

        cKey = this.findChildFieldWithClass("workitem_row_key");
        cValue = this.findChildFieldWithClass("workitem_row_value");
        
        return [ cKey.getValue(), cValue.getValue() ];
    }
});


var HashField = Class.create(Field, {

    initialize : function ($super, parent, value, rw) {

        $super(parent, rw);

        this.element = document.createElement('div');
        this.parent.appendChild(this.element);

        this.element.setAttribute('class', 'workitem_hash');

        for (var key in value) {

            var eRow = createWorkitemRow(this.element);
            new HashEntryField(eRow, key, value[key], rw);
        }

        if (this.rw) renderAddFieldButton(this.element);
    },

    getValue : function () {

        var result = new Hash();

        var children = this.element.immediateDescendants();
        for (var i=0; i < children.length; i++) {

            var child = children[i];

            if (child.getAttribute("class") != "workitem_row") continue;

            var entryValue = child.owfeField.getValue();

            var k = entryValue[0];
            var v = entryValue[1];

            if (k == "") k = "undefined";

            var counter = 1;

            while (result.keys().include(k)) {

                k = entryValue[0] + counter;
                counter += 1;
            }

            result[k] = v;
        }

        return result;
    }
});


//
// FIELD BUILDERS

function newField (parent, value, rw) {

    var parentClass = parent.getAttribute("class");

    //console.debug("parentClass : "+parentClass);
    //console.debug("newField() value : '" + value.toString() + "'");

    if (value == NoTypeField && parentClass == "workitem_hash") {

        var elt = createWorkitemRow(parent);
        new HashEntryField(elt, NoTypeField, NoTypeField, rw);
    }
    else if (value == NoTypeField) {

        new NoTypeField(parent, value, rw);
    }
    else if (typeof value == "string") {

        new StringField(parent, value, rw);
    }
    else if (typeof value == "number") {

        new NumberField(parent, value, rw);
    }
    else if (typeof value == "boolean") {

        new BooleanField(parent, value, rw);
    }
    else {

        new HashField(parent, value, rw);
    }
}

function newJsonField (parent, json_value, rw) {

    var value = eval("("+json_value+")");
    //var value = json_value;

    newField(parent, value, rw);
}

function replaceField (target, value, rw) {

    target = $(target);
    var parent = target.parentNode;
    target.remove();
    newField(parent, value, rw);
}


//
// FORM FUNCTIONS

function doAct (action) {

    $('workitem_form_json').value = $('workitem').owfeField.getValue().toJSON();
    $('workitem_form_action').value = action;
    $('workitem_form').submit();
}

function doSave () {

    doAct('save');
}

function doProceed () {

    doAct('proceed');
}

