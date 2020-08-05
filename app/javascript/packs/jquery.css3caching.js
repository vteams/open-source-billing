(function($) {
  function parseImagesFromCSS(doc) {
    var i, j,
      rule,
      image,
      pattern = /url\((.*)\)/,
      properties = ['background-image', '-webkit-border-image'],
      images = {};

    if (doc.styleSheets) {
      for (i = 0; i < doc.styleSheets.length; ++i) {
        images = $.extend(images, parseImagesFromCSS(doc.styleSheets[i]));
      }
    } else if (doc.cssRules) {
      for (i = 0; i < doc.cssRules.length; ++i) {
        rule = doc.cssRules[i];
        if (rule.styleSheet) {
          images = $.extend(images, parseImagesFromCSS(rule.styleSheet));
        } else if (rule.style) {
          for (j=0; j < properties.length; j++) {
            image = pattern.exec(rule.style.getPropertyValue(properties[j]));
            if (image && image.length === 2) {
              images[image[1]] = image[0];
            }
          }
        }
      }
    }

    return images;
  };

  $.extend({
    preload: {
      images: function(doc) {
        doc = doc || document;
        var images = $.map(parseImagesFromCSS(doc), function(url) { return url; }),
          head = doc.getElementsByTagName('head')[0],
          style = doc.createElement('style');
        style.type = 'text/css';
        style.id = 'preload';
        style.innerHTML = 'body::after { content: ' + images.join(' ') + '; display: none; }';
        head.appendChild(style);
      }
    }
  });
})(jQuery);