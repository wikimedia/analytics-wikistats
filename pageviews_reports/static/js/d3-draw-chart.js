
function drawChart(data, containerId) {

  var max_val = d3.max(data);
  var min_val = d3.min(data);

  var w = 5,
      h = 40;

  var x = d3.scale.linear()
  .domain([0, 1])
  .range([0, w]);


  // made the lower bound smaller so that
  // the minimum value doesn't get squashed to zero
  var y = d3.scale
            .linear()
            .domain([min_val * 0.8, max_val])
            .rangeRound([0, h]);


  var chart = d3.select("#"+containerId)
                .append("svg")
                .attr("class", "chart")
                .attr("width", w * data.length - 1)
                .attr("height", h);

  chart.selectAll("rect")
       .data(data)
       .enter()
       .append("rect")
       .attr("x",      function(d, i) { return x(i) - .5;      })
       .attr("y",      function(d)    { return h - y(d) - .5;  })
       .attr("height", function(d)    { return y(d);           })
       .attr("width", w);
};

