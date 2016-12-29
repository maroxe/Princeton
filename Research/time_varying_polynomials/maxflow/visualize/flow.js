var color_edges = '#6FB1FC';
var color_flow = 'red';
var scale_x = 1;
var scale_y = 1;
graph = [
[ 0, 5, 4, 4, 7, 0, 0, 0, 0],
[0, 0, 0, 0, 4, 0, 0, 0, 2],
[0, 0, 0, 0, 5, 6, 0, 0, 0],
[0, 0, 0, 0, 0, 4, 1, 0, 0],
[0, 0, 0, 0, 0, 0, 0, 3, 2],
[0, 0, 0, 0, 0, 0, 2, 3, 4],
[0, 0, 0, 0, 0, 0, 0, 0, 8],
[0, 0, 0, 0, 0, 0, 0, 0, 7],
[0, 0, 0, 0, 0, 0, 0, 0, 0],
];


pos = [
    [160.11,204.62],
    [372.50,47.94],
    [300.88,290.00],
    [169.18,393.97],
    [431.74,156.67],
    [431.92,379.64],
    [513.06,501.80],
    [497.71,243.80],
    [795.18,247.92],
];

node_names = ['S', 'B', 'C', 'D', 'F', 'G', 'H', 'I', 'T'];
n_nodes = node_names.length;


var cy = cytoscape({
    container: document.getElementById('cy'), // container to render in
    style: [
        {
            selector: 'node',
            css: {
                'content': 'data(name)',
                'text-valign': 'center',
                'text-halign': 'center',
                'width' : '50',
                'height' : '50',
                'text-outline-color': '#6FB1FC',
                'background-color': '#6FB1FC',
                'color': '#fff'
            }
        },
        {
            selector: 'edge',
            css: {
                'target-arrow-shape': 'triangle',
                //'target-arrow-color': 'red',
                //'curve-style': 'segments',
                
                'line-color': 'data(color)',
                'opacity': 'data(opacity)',
                'width': 'data(strength)',
                'label': 'data(label)',
                'text-valign': 'top',
                'text-halign': 'right'
            }
        },
    ]
});

for(var i = 0; i < graph.length; i++) {
    cy.add(
        { 
            group: "nodes", 
            data: { id: 'n' + i, name: node_names[i] },
            position: {x: pos[i][0]*scale_x,  y: pos[i][1]*scale_y }
        }
    );
}


for(var i = 0, edge_counter = 0; i < n_nodes; i++) {
    for(var j = 0; j < n_nodes; j++, edge_counter ++) {
        if(graph[i][j] > 0) {
            cy.add({   
                group: "edges",
                data: {
                    id: 'f' + edge_counter,
                    source: 'n'+i,
                    target: 'n'+j,
                    strength: 0,
                    color: color_flow,
                    opacity: 1.,
                    label: ''
                }
            });

            cy.add({   
                group: "edges",
                data: {
                    id: 'e' + edge_counter,
                    source: 'n'+i,
                    target: 'n'+j,
                    strength: 0,
                    color: color_edges,
                    opacity: 0.5,
                    label: ''
                }
            });
        }

    }
}



cy.layout({
    name: 'preset'
});


$('#clickme').click(function() {
    //cy.$('#e0-1').data('strength', '5');
});

var update_graph = function (ui_value){
            var edge_counter = 0;
            var flow_S = 0;
            for(var i = 0; i < n_nodes; i++) 
                for(var j = 0; j < n_nodes; edge_counter++, j++) {
                    if(graph[i][j]){

                        var cap = Math.round(graph_data[edge_counter][ui_value]*10)/10;
                        var flow = Math.round(flow_data[edge_counter][ui_value]*10)/10;
                        var pct = Math.round(flow/cap*100) + '%';
                        pct = pct + '(' + flow + ','  + cap + ')';
                        cy.$('#e'+edge_counter).data('strength', graph_data[edge_counter][ui_value]);
                        cy.$('#f'+edge_counter).data('strength', flow_data[edge_counter][ui_value]);
                        p = 
                        cy.$('#f'+edge_counter).data('label', pct);
                        if(i == 0) flow_S += flow_data[edge_counter][ui_value];
                    }
                }

        
    t = time_points[ui_value];
    $( "#time" ).val(t);
    $( "#flow" ).val(flow_S);
};



$( "#slider-range-min" ).slider({
    range: "min",
    value: 0,
    min: 0,
    max: graph_data[0].length-1,
    slide: function( event, ui ) {
        update_graph(ui.value);
    }
});

// .each(function() {

//     var opt = $(this).data().uiSlider.options;
//     var vals = opt.max - opt.min;

//     for (var i = 0; i <= vals; i++) {
//         var el = $('<label>' + time_points[2*i] + '</label>').css('left', (2*i/vals*100) + '%');
//         // Add the element inside #slider
//         $("#slider-range-min").append(el);
//     }
// });



// Plot
function zip(arrays) {
    return arrays[0].map(function(_,i){
        return arrays.map(function(array){return array[i]});
    });
}


plot_flow = function(S, T) {
    i = node_names.indexOf(S);
    j = node_names.indexOf(T);
    y = graph_data[i*n_nodes+j];
    y2 = flow_data[i*n_nodes+j];
    x = time_points;
    
    zipxy = zip([x, y]);
    zipxy2 = zip([x, y2]);
    $.plot($("#flot-placeholder"), [ zipxy, zipxy2 ]);
};

$('#plot-button').click(function() {
    plot_flow($("#source").val(), $("#target").val());
});

update_graph(0);
plot_flow($("#source").val(), $("#target").val());
