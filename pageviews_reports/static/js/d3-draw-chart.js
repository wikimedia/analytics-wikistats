
function drawChart(data, containerId) {

  var max_val = d3.max(data);
  var min_val = d3.min(data);

  var w = 5,
      max_h = 50,
      min_h = 5;

  var x = d3.scale.linear()
            .domain([0, 1])
            .range( [0, w]);


  // made the lower bound smaller so that
  // the minimum value doesn't get squashed to zero
  var y = d3.scale
            .linear()
            .domain([min_val * 0.8, max_val])
            .rangeRound([min_h, max_h]);


  var chart = d3.select("#"+containerId)
                .append("svg")
                .attr("class", "chart")
                .attr("width", w * data.length - 1)
                .attr("height", max_h);

  chart.selectAll("rect")
       .data(data)
       .enter()
       .append("rect")
       .attr("x",      function(d, i) { return x(i) - .5;      })
       .attr("y",      function(d)    { return max_h - y(d) - .5;  })
       .attr("height", function(d)    { return y(d);           })
       .attr("width", w);
};

