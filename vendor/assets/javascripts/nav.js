/* Credits: Stu Nicholls */
/* URL: http://www.stunicholls.com/menu/pro_drop_1/stuHover.js */

stuHover = function() {
	var cssRule;
	var newSelector;
	for (var i=0; i< document.styleSheets.length; i++)
		for (var x=0; x< document.styleSheets[i].rules.length; x++)
			{
			cssRule = document.styleSheets[i].rules[x];
			if (cssRule.selectorText.indexOf("LI:hover") >= 0)
			{
				 newSelector = cssRule.selectorText.replace(/LI:hover/gi, "LI.iehover");
				document.styleSheets[i].addRule(newSelector , cssRule.style.cssText);
			}
		}
	var getElm = document.getElementById("nav").getElementsByTagName("LI");
	for (var i=0; i<getElm.length; i++) {
		getElm[i].onmouseover=function() {
			this.className+=" iehover";
		}
		getElm[i].onmouseout=function() {
			this.className=this.className.replace(new RegExp(" iehover\\b"), "");
		}
	}
}
if (window.attachEvent) window.attachEvent("onload", stuHover);