(function ($) {
    $.fn.ellipsis = function (options) {

        // デフォルトオプション
        var full_text = ''
        var defaults = {
            row: 1, // 省略行数
            char: '...' // 省略文字
        };

        options = $.extend(defaults, options);

        this.each(function () {

            // 現在のテキストを取得
            var $this = $(this);
            var text = $this.text();
            full_text = text
            // 1行分の高さを取得
            $this.text('a');
            var rowHeight = getHeight($this,options); //$this.height();
//            console.log(rowHeight)
            // 一旦すべて空にする
            $this.text('');
            // 行数カウント
            var rowCount = 1;
            // 省略するかのフラグ
            var flag = false;

            var height = 0;

            for (var i = 0; i < text.length; i++) {

                // 1文字ずつ取得
                var s = text.substring(i, i + 1);
                // テキストを足していく
                $this.text($this.text() + s);
                // 現在の高さを取得
                height = $this.height();
                if (height !== 0 && height !== rowHeight) {
                    // 高さが0意外かつ前回の高さと異なる場合
                    // 今の高さを保持
                    rowHeight = height;
                    // 行数インクリメント
                    rowCount++;

                    // 指定の行数を超えた時に終了
                    if (rowCount > options.row) {
                        flag = true;
                        break;
                    }
                }
            }

            if (flag) {
                text = $this.text();

                //Start changes for qtip
                $this.attr("title", full_text);
                var tagn = $this.get(0).tagName;
                var xpos = -12
                var ypos = -12
                if (tagn == "A") { //In case of <a> tag position should remain same
                    xpos = 0
                    ypos = 0
                }
                $this.qtip(
                    {position: {adjust: {x: xpos, y: ypos}}}
                );
                //End changes for qtip
                var breaker = 0;
                while (true) {

                    // 1文字ずつ減らしながら行数を見ていく
                    text = text.substring(0, text.length - 1);
                    $this.text(text + options.char);
                    height = $this.height();
//                    console.log("Height: " + height + " Row Height: " +rowHeight + " Text: " + $this.text() + "");
                    if (height < rowHeight) {
                        break;
                    }

                }
            }

        });

        return this;
    };

    function getHeight(elem,options) {
        var $sourceRow = elem.parents("tr").first();
        var height = 0;

        if ($sourceRow.length > 0) {
            var $rowCopy = $sourceRow.clone();

            $rowCopy.find(".text-overflow-class").each(function () {
                jQuery(this).text('a');
            });

            $rowCopy.insertAfter($sourceRow);
            height = $rowCopy.find(".text-overflow-class").first().height();
            $rowCopy.remove();
        }
        else {
            height = elem.height();

        }
        return height;
    }

})(jQuery);

