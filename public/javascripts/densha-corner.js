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

// in order to be used in other projects, this javascript 'library' 
// doesn't rely on prototype like the rest of Densha's javascript code.


//
// box functions

function divClear (parent) {

    var e = document.createElement("div");
    e.setAttribute("style", "clear: both;");
    parent.appendChild(e);
}

function buildCorner (parent, direction) {

    var e = document.createElement("div");
    e.setAttribute("class", "corner_"+direction);
    parent.appendChild(e);
    return e;
}

function buildRuler (parent, height, width, float) {

    margin_value = "1px";

    margin = "margin-top";
    if (buildRuler.arguments.length > 4) margin_value = ""+arguments[4]+"px";
    if (height > width) margin = "margin-"+float;

    var e = document.createElement("div");
    e.setAttribute("class", "corner_ruler");
    e.setAttribute(
        "style", 
        "float: "+float+"; "+
        "width: "+width+"px; height: "+height+"px; "+
        margin+": "+margin_value+";")
    parent.appendChild(e);
    return e;
}

function buildBox (width, height) {

    var ebox = document.createElement("div");
    ebox.setAttribute(
        "style",
        "width: "+width+"px; height: "+height+"px; "+
        "margin: 0em auto 0 auto"
    );

    var w = width - 12;
    var h = height - 12;

    buildCorner(ebox, "nw");
    buildRuler(ebox, 1, w, "left");
    buildCorner(ebox, "ne");
    divClear(ebox);

    buildRuler(ebox, h, 1, "left");
    var econtent = document.createElement("div");
    econtent.setAttribute("class", "corner_content");
    econtent.setAttribute(
        "style",
        "float: left; "+
        "width: "+w+"px; height: "+h+"px;"
    );
    ebox.appendChild(econtent);
    ebox.econtent = econtent; // direct pointer
    buildRuler(ebox, h, 1, "right");
    divClear(ebox);

    buildCorner(ebox, "sw");
    buildRuler(ebox, 1, w, "left", 4);
    buildCorner(ebox, "se");
    divClear(ebox);

    return ebox;
}

