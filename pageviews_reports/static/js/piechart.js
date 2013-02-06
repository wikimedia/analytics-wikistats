
function PieChart(params) {
  this.width            = params.width;
  this.height           = params.height;
  this.data             = params.data;
  this.containerId      = params.containerId;
  this.outerRadiusRatio = params.outerRadiusRatio;
  this.innerRadiusRatio = params.innerRadiusRatio;
  this.radius           = Math.min(this.width, this.height) / 2;
};


PieChart.prototype.drawChart = function() {

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
  .range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]);


  this.svg = d3
  .select("#"+this.containerId)
  .append("svg")
  .attr("width", this.width)
  .attr("height", this.height)
  .append("g")
  .attr("transform", 
        "translate(" + 
          this.width  / 2 + "," + 
          this.height / 2 + 
        ")"
       );

  this.g = this.svg
  .selectAll(".arc")
  .data(this.pie(this.data))
  .enter()
  .append("g")
  .attr("class", "arc");
};

PieChart.prototype.drawLabels = function() {

  var self = this;

  self.g.append("path")
  .attr("d", self.arc)
  .style("fill", function(d) { return self.color(d.data.label); });

  self.g.append("text")
  .attr("transform", function(d) { 
    console.log(self.arc.centroid(d));
    return "translate(" + self.arc.centroid(d) + ")"; 
  }) 
  .attr("dy", ".10em")
  .style("text-anchor", "middle")
  .text(function(d) { return d.data.label; });


  self.g.append("text")
  .attr("transform", function(d) { 
    var pos = self.arc.centroid(d);
    pos[1] += 10;
    return "translate(" + pos + ")"; 
  }) 
  .attr("dy", ".95em")
  .style("text-anchor", "middle")
  .text(function(d) { 
    return d.data.pageview_count; 
  });

};
