
function TooltipPieChart(params) {
  this.width            = params.width;
  this.height           = params.height;
  this.data             = params.data;
  this.containerId      = params.containerId;
  this.observedId       = params.observedId;
  this.outerRadiusRatio = params.outerRadiusRatio;
  this.innerRadiusRatio = params.innerRadiusRatio;
  this.titleText        = params.titleText;
  this.radius           = params.radius;
  
  
  var titleDivContent = '<div style="background-color: yellow; margin-left:auto;margin-right:auto;"><h2 align="center">'+this.titleText+'</h2></div>';
  $("#"+this.containerId).html(titleDivContent);
};


TooltipPieChart.prototype.init = function() {
  // hide Piechart and install callbacks for mouse over

  var containerSelector = "#"+this.containerId;
  var observedSelector  = "#"+this.observedId;

  $( containerSelector).css("position","absolute");
  $( containerSelector).css("display" ,"none"    );
  $( observedSelector).mousemove(function(e){
    $(containerSelector).css("left", e.pageX+20);
    $(containerSelector).css("top" , e.pageY+10);
  });

  $( observedSelector).hover(
    /*
     *function(){ $( containerSelector ).fadeIn( "fast",function(){  debugger;  }); },
     *function(){ $( containerSelector ).fadeOut("fast",function(){  debugger;  }); }
     */
    function(){ $( containerSelector ).show(); },
    function(){ $( containerSelector ).hide(); }
  );
};

TooltipPieChart.prototype.drawChart = function() {

  this.pie = d3
  .layout
  .pie()
  .sort(null)
  .value(function(d) { 
    //console.log(d);
    //console.log(d.pageview_count);
    return d.pageview_count; 
  });

  this.arc = d3
  .svg
  .arc()
  .outerRadius(this.radius * this.outerRadiusRatio )
  .innerRadius(this.radius * this.innerRadiusRatio );

  this.color = d3
  .scale
  .ordinal()
  .range(["#CFF016","#16DAF0","#16F098","#F0AE16","#F05316","#46D130"]);


  this.svg = d3
  .select("#"+this.containerId)
  .append("svg")
  .attr("width", this.width)
  .attr("height", this.height)
  .append("g")
  .attr("transform", 
        "translate(" + 
          (this.width ) / 2 + "," + 
          (this.height) / 2 + 
        ")"
       );

  this.g = this.svg
  .selectAll(".arc")
  .data(this.pie(this.data))
  .enter()
  .append("g")
  .attr("class", "arc");
};

TooltipPieChart.prototype.drawLabels = function() {

  var self = this;

  self.g
  .append("path")
  .attr("d", self.arc)
  .style("fill", function(d) { return self.color(d.data.label); });


  var placedLabels = new Array;


  self.g.append("text")
  .attr("transform", function(d) { 

    //console.log(d);
    var pos  = self.arc.centroid(d);
    var x    = pos[0];
    var y    = pos[1];
    var h    = Math.sqrt(x*x + y * y);

    var labelx = x / h * (self.radius+10);
    var labely = y / h * (self.radius+10);

    return "translate(" + labelx + "," + labely + ")"; 
  }) 
  .attr("dy", ".10em")
  .style("text-anchor", "middle")
  .text(function(d) { return d.data.pageview_count; });

    
  // TODO:  
  // positions fine-tuned, need to fix this
  self
  .g
  .data(self.data)
  .append("rect")
  .attr( "x", this.radius + 30  )
  .attr( "y", function(d, i){ 
    console.log(i);
    return ((i) *  20) - 115;})
  .attr( "width" , 10)
  .attr( "height", 10)
  .style("fill" , function(d,i) { 
    return self.color(d.label);
  });


   
  // TODO:  
  // positions fine-tuned, need to fix this
  self
  .g
  .data(self.data)
  .append("text")
  .attr("x", this.radius + 50)
  .attr("y", function(d, i){ return ((i+1) *  20)  - 125;})
  .text(function(d) {
    return d.label;
  });
     


  //console.log(self.g);
};
