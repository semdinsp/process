/*
 *  OpenWFEru densha - open source ruby workflow and bpm engine
 *  (c) 2007 OpenWFE.org
 *
 *  OpenWFEru densha is freely distributable under the terms 
 *  of a BSD-style license.
 *  For details, see the OpenWFEru web site: http://openwferu.rubyforge.org
 *
 *  Made in Japan
 *
 *
 *  John Mettraux
 *  Juan-Pedro Paredes
 */

//
// some functions

function tdiv (text) {

    var attributes = {};
    if (tdiv.arguments.length > 1) attributes = tdiv.arguments[1];

    var e = new Element("div", attributes);
    e.appendChild(document.createTextNode(text));
    return e;
}

function divClear () {

    var e = new Element('div', { style: "clear: both;" });
    if (divClear.arguments.length > 0) divClear.arguments[0].appendChild(e);
    return e;
}

function newDiv () {

    var attributes = {};

    if (newDiv.arguments.length == 2) {
        attributes["id"] = newDiv.arguments[0];
        attributes["class"] = newDiv.arguments[1];
    }
    else {
        attributes["class"] = newDiv.arguments[0];
    }

    return new Element("div", attributes);
}

//
// The expression classes

var Expression = Class.create({

    initialize : function (container, exp_id, array) {

        this.container = container;

        this.exp_id = exp_id;

        this.exp_name = array[0];
        this.exp_attributes = $H(array[1]);
        this.exp_children = array[2];

        this.div = newDiv(this.exp_id, this.cssPrefix());

        this.div.fluo_exp = this;

        this.content_div = this.div;
            // by default, the content_div is the div
            // expressions like ParticipantExpression twist that

        this.container.appendChild(this.div);

        this.render();
    },

    render : function () {

        this.renderHead();
        this.renderChildren();
        this.renderFoot();
    },

    renderHead : function () {

        var eDiv = newDiv(this.cssPrefix()+"_head");

        eDiv.appendChild(tdiv(this.exp_name));

        this.exp_attributes.each(function (att) {

            eDiv.appendChild(tdiv("" + att.key + " : " + att.value));
        });

        this.content_div.appendChild(eDiv);
    },

    renderFoot : function () {
        // no relevant implementation at this level
    },

    renderChildren : function () {

        for (var i=0; i<this.exp_children.length; i++) {

            child = this.exp_children[i];

            if (( ! this.getFluoContainer().showMinorExpressions) &&
                MINOR_EXPRESSIONS.include(child[0])) {

                continue;
            }

            this.renderChild(i, child);
        }
    },

    renderChild : function (index, child) {

        var container = this.content_div;

        if (arguments.length > 2) container = arguments[2];

        return renderExpression(container, this.exp_id+"."+index, child);
    },

    cssName : function () {

        return "no-css-name";
    },

    cssPrefix : function () {

        return "fluo_exp_" + this.cssName();
    },

    fetchAttribute : function (attname) {

        var v = this.exp_attributes[attname];
        if (v != null) return v;

        v = this.exp_attributes["field-"+attname];
        if (v != null) return "field : "+v;

        v = this.exp_attributes["variable-"+attname];
        if (v != null) return "variable : "+v;

        return "";
    },

    fetchText : function () {

        return this.exp_children[0][0];
    },

    getFluoContainer : function () {

        var id = this.content_div.id;
        var i = id.indexOf(ROOT_EXP_ID);
        id = id.substring(0, i);
        return $(id);
    },

    attMaxSize : function () {

        var max = this.exp_name.length;
        this.exp_attributes.each(function (e) {
            var l = e.key.length + e.value.length;
            if (l > max) max = l;
        });

        return max;
    }
});

var SequenceExpression = Class.create(Expression, {

    cssName : function () {

        return "sequence";
    },

    renderHead : function ($super) {

        if (this.exp_name != "sequence") $super();
            // else don't write "sequence"
    },

    renderChild : function ($super, index, child) {

        $super(index, child);

        if (child == this.exp_children.last()) return;

        var dArrow = new Element("div", {});
        var iArrow = new Element("img", { src: "/images/fluo/adown.png" });

        dArrow.appendChild(iArrow);
        this.content_div.appendChild(dArrow);
    }
});

var ConcurrenceExpression = Class.create(Expression, {

    cssName : function () {
        return "concurrence";
    },

    horizontalBar : function () {

        var eBar = new Element('div', { "class": "fluo_pixel" });
        eBar.setStyle({ "width": "70%", "height": "1px" });

        return eBar;
    },

    renderChildren : function () {

        this.content_div.appendChild(this.horizontalBar());

        var eChildren = new Element(
            'div', { "class": "fluo_exp_concurrence_children" });

        var width = 100;
        if (width > 0) width = 100 / this.exp_children.length;

        for (var i=0; i<this.exp_children.length; i++) {

            var child = this.exp_children[i];

            var eChild = newDiv("fluo_exp_concurrence_child");
            eChild.setStyle({ "width": ""+width+"%" });

            renderExpression(eChild, this.exp_id+"."+i, child);

            eChildren.appendChild(eChild);
        }
        this.content_div.appendChild(eChildren);

        this.content_div.appendChild(divClear());

        this.content_div.appendChild(this.horizontalBar());
    }
});

var ProcessDefinitionExpression = Class.create(Expression, {

    cssName : function () {
        return "process_definition";
    }
});

var NoChildrenExpression = Class.create(Expression, {

    renderChildren : function () {

        // none to render
    }
});

var UnknownExpression = Class.create(NoChildrenExpression, {

    cssName : function () {
        return "unknown";
    },

    render : function () {

        var width = this.attMaxSize() * 10;
        var height = 30 + (20 * this.exp_attributes.size());

        var ebox = buildBox(width, height);
        this.div.appendChild(ebox);

        ebox.setAttribute("id", this.div.getAttribute("id"));
        this.div.setAttribute("id", "real__"+this.div.getAttribute("id"));
            // stealing the id of the containing box
            // for workitem localization

        this.content_div = ebox.econtent;
            // pointing the content_div to our new content box

        this.renderHead();
    }
});

var ParticipantExpression = Class.create(NoChildrenExpression, {

    cssName : function () {
        return "participant";
    },

    render : function () {

        var width = this.attMaxSize() * 10;
        var height = 30 + (20 * this.exp_attributes.size());

        var ebox = buildBox(width, height);
        this.div.appendChild(ebox);

        ebox.setAttribute("id", this.div.getAttribute("id"));
        this.div.setAttribute("id", "real__"+this.div.getAttribute("id"));
            // stealing the id of the containing box
            // for workitem localization

        this.content_div = ebox.econtent;
            // pointing the content_div to our new content box

        this.renderHead();
    },

    renderHead : function () {

        var eDiv = newDiv(this.cssPrefix()+"_head");

        var ref = this.fetchAttribute('ref');
        if (ref == null || ref == "") ref = this.fetchText();
        var activity = this.exp_attributes['activity'];

        //eDiv.appendChild(
        //    tdiv(ref, { class: "fluo_exp_head_div" }));
        eDiv.appendChild(tdiv(ref));

        if (activity) eDiv.appendChild(tdiv(activity));

        this.content_div.appendChild(eDiv);
    }
});

var CaseExpression = Class.create(Expression, {

    cssName : function () {
        return "case";
    },

    renderHead : function () {

        var eDiamond = new Element(
            "img",
            { "src": "/images/fluo/diamond.png" });
        this.content_div.appendChild(eDiamond);
        this.content_div.appendChild(document.createTextNode(this.exp_name));

        this.content_div.appendChild(divClear());
    },

    renderChildren : function () {

        var consequence = false;

        for (var i=0; i<this.exp_children.length; i++) {

            var child = this.exp_children[i];

            if (i == this.exp_children.length - 1 && ( ! consequence))
                consequence = true;

            if (consequence) {
                this.renderConsequence(i, child);
                this.content_div.appendChild(divClear());
            }
            else {
                this.renderCondition(i, child);
            }

            consequence = ( ! consequence);
        }
    },

    renderFoot : function () {

        var eDiamond = new Element(
            "img", 
            { "src": "/images/fluo/diamond.png" });
        this.content_div.appendChild(eDiamond);
    },

    renderCondition : function (index, item) {

        var e = newDiv(this.cssPrefix()+"_condition");

        this.renderChild(index, item, e);

        this.content_div.appendChild(e);
    },

    renderConsequence : function (index, child) {

        var e = newDiv(this.cssPrefix()+"_consequence");

        this.renderChild(index, child, e);

        this.content_div.appendChild(e);

        var earrow = newDiv(this.cssPrefix()+"_arrow");
        earrow.appendChild(new Element(
            "img",
            { "src": "/images/fluo/aright.png" }));

        this.content_div.appendChild(earrow);
    }
});

var IfExpression = Class.create(CaseExpression, {

    cssName : function () {
        return "if";
    },

    renderChildren : function () {

        var offset = 1;
        var aTest = this.exp_attributes['test'];
        var cCondition = this.exp_children[0];

        if (aTest) {
            offset = 0;
            cCondition = aTest;
        }

        this.renderCondition(cCondition);

        var cThen = this.exp_children[0 + offset];
        var cElse = this.exp_children[1 + offset];

        var eThen = newDiv(this.cssPrefix()+"_then");
        var eElse = newDiv(this.cssPrefix()+"_else");

        if (cThen) {
            eThen.appendChild(tdiv("then"));
            this.renderChild(0 + offset, cThen, eThen);
        }
        if (cElse) {
            eElse.appendChild(tdiv("else"));
            this.renderChild(1 + offset, cElse, eElse);
        }

        this.content_div.appendChild(eThen);
        this.content_div.appendChild(eElse);

        this.content_div.appendChild(divClear());
    },

    renderCondition : function (item) {

        var e = newDiv(this.cssPrefix()+"_condition");

        if (typeof item == 'string') {
            e.appendChild(document.createTextNode(item));
        }
        else {
            this.renderChild(0, item, e);
        }

        this.content_div.appendChild(e);
    }
});


//
// the TOP

var ROOT_EXP_ID = "_exp_0";

var EXPRESSIONS = {

    "case" : CaseExpression,
    "concurrence" : ConcurrenceExpression,
    "cursor" : SequenceExpression,
    "equals" : Expression,
    "if" : IfExpression,
    "loop" : SequenceExpression,
    "process-definition" : ProcessDefinitionExpression,
    "sequence" : SequenceExpression,
    "participant" : ParticipantExpression,
    "reval" : Expression,
    "set" : Expression,
    "sleep" : Expression
}

var MINOR_EXPRESSIONS = $A([
    "set", "unset"
])


function toggleMinorExpressions (parent) {

    parent = $(parent);

    parent.showMinorExpressions = ! parent.showMinorExpressions;

    renderExpression(parent, null, parent.originalArray);

    return false;
}

function renderToggleButton (parent) {

    var ebutton = new Element(
        "a", 
        { 
            "class": "fluo_toggle_button",
            "href": "#",
            "onclick": "return toggleMinorExpressions('"+parent.id+"');" 
        });

    var text = "less info";
    if ( ! parent.showMinorExpressions) text = "more info";

    ebutton.appendChild(document.createTextNode(text));

    parent.appendChild(ebutton);
}


/*
 * The function that does all the rendering.
 */
function renderExpression (parent, exp_id, a) {

    parent = $(parent);

    var top = (exp_id == null);

    if (top) {

        exp_id = parent.id + ROOT_EXP_ID;

        parent.childElements().each(function (elt) {
            elt.remove();
        });
    }

    var result = null;

    var clazz = EXPRESSIONS[a[0]];

    if (clazz == null) 
        result = new UnknownExpression(parent, exp_id, a);
    else
        result = new clazz(parent, exp_id, a);

    if (top) {

        //parent.showMinorExpressions = true;
        parent.originalArray = a;

        renderToggleButton(parent);

        if (parent.taggedExpressions) {
            tagExpressionsWithWorkitems(parent, parent.taggedExpressions);
        }
    }

    return result;
}

/*
 * Pass a list of expression ids and their expression representation will
 * get a nice border.
 */
function tagExpressionsWithWorkitems (root, expression_ids) {

    root = $(root);
    var root_id = root.getAttribute("id");

    expression_ids = $A(expression_ids);

    expression_ids.each(function (exp_id) {

        $(root_id+"_exp_"+exp_id).addClassName("fluo_exp_has_workitem");
    });

    root.taggedExpressions = expression_ids;
}

