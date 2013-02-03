
function Drawpad(divId) {
  var divLegend = document.getElementById(divId);
  this.paper = new Raphael(divLegend);
  this.cell  = this.paper.rect(10,10,160,50);
  this.cell.attr({fill: '#00ff00'});

  console.log("cell.getBBox().x = " + this.cell.getBBox().x);
  console.log("cell.getBBox().y = " + this.cell.getBBox().y);

};

Drawpad.prototype.createComment = function(x,y,size,text) {
  var padding      = 4;
  var group        = this.paper.set();
  var text         = this.createText(x,y,size,text);
  var rectangle    = 
    this.paper.rect(
      text.getBBox().x - padding,
      text.getBBox().y - padding,
      text.getBBox().width  + 2 * padding ,
      text.getBBox().height + 2 * padding 
      );
 rectangle.attr({fill: "yellow"});

 rectangle.toBack();

 //group.push(rectangle);
 //group.push(text);

  return rectangle;
};


Drawpad.prototype.createText   = function(x,y,size,text) {
  var text = this.paper.text(x,y,text);
  text.translate( 
    (this.cell.getBBox().width   + text.getBBox().width  )/2 ,
    (this.cell.getBBox().height  + text.getBBox().height )/2
  );
  text.attr({"font-size"  : size});
  //text.attr({"text-anchor": "start"});
  return text;
};


Drawpad.prototype.drawEverything = function() {
  this.textDelta                        = this.createText(-60 , 0  , 11,"+8.13%, ");
  this.textPercentOfMonth               = this.createText(  0 , 0  , 11,"19.2%, ");
  this.textMonthlyRanking               = this.createText( 60 , 0  , 11,"3rd");
  this.textMonthlyPageviewCount         = this.createText(  0 , 20 , 13,"430 M");

  this.textMonthlyPageviewCount.attr({"font-weight": "bold" });

  this.textDeltaComment                 = this.createComment(150 ,     150 , 14 , "Delta between\n previous and current month");
  this.textMonthlyPageviewCountComment  = this.createComment(150 ,     110 , 14 , "Monthly Pageview count");
  this.textPercentOfMonthComment        = this.createComment(150 ,      71 , 14 , "Percentage of monthly\n pageviews");
  this.textMonthlyRankingComment        = this.createComment(150 ,      30 , 14 , "Ranking within \nthe current month");

  this.arrow(this.textDeltaComment                ,  this.textDelta);
  this.arrow(this.textPercentOfMonthComment       ,  this.textPercentOfMonth);
  this.arrow(this.textMonthlyRankingComment       ,  this.textMonthlyRanking);
  this.arrow(this.textMonthlyPageviewCountComment ,  this.textMonthlyPageviewCount);
};

Drawpad.prototype.arrow = function(from,to) {
  var arrowHeadSize = 8;
  var x1 = from.getBBox().x ;
  var y1 = from.getBBox().y + (from.getBBox().height/2);
  var x2 =   to.getBBox().x + (to.getBBox().width  / 2);
  var y2 =   to.getBBox().y + (to.getBBox().height / 2) + 6;

  var midX = Math.floor( x1 + ( (x2-x1) *  0.3 ) );
  var midY = Math.floor( y1 + ( (y2-y1) * -0.2 ) );

  var arrowBody = this.paper.path(
    "M" + x1   + "," + y1 +
    "L" + midX + "," + midY +
    "L" + x2   + "," + y2
    );

  var slope = Math.atan2(midX-x2,y2-midY);
  var angleOrientationArrowHead =  90 + ( (slope / (2 * Math.PI)) * 360 );

  console.log("angle="+angleOrientationArrowHead);
  var arrowHead = this.paper.path(
  "M"  +  x2  + " " + y2  + 
  " L" + (x2  - arrowHeadSize)  + " " + (y2  - arrowHeadSize) + 
  " L" + (x2  - arrowHeadSize)  + " " + (y2  + arrowHeadSize) + 
  " L" +  x2  + " " + y2 
  ).attr("fill","black")
   .rotate(angleOrientationArrowHead,x2,y2);

};

