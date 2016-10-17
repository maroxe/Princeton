var color_edges = '#6FB1FC';
var color_flow = 'green';

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
       [160.118, 204.622],
       [349.777, 75.724],
       [300.886, 290.007],
       [194.432, 353.577],
       [441.85, 190.343],
       [498.42, 356.915],
       [563.57, 478.236],
       [536.43, 253.91], 
       [711.86, 271.49]];

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
            position: {x: pos[i][0],  y: pos[i][1] }
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
                    label: '',
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
                    opacity: 0.3,
                    label: '',
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
            var flow = 0;
            for(var i = 0; i < n_nodes; i++) 
                for(var j = 0; j < n_nodes; edge_counter++, j++) {
                    if(graph[i][j]){

                        var cap = Math.round(graph_data[edge_counter][ui_value]);
                        var flow = Math.round(flow_data[edge_counter][ui_value]);
                        var pct = Math.round(flow/cap*100) + '%';
                        pct = pct + '(' + flow + ','  + cap + ')';
                        cy.$('#e'+edge_counter).data('strength', graph_data[edge_counter][ui_value]/2.);
                        cy.$('#f'+edge_counter).data('strength', flow_data[edge_counter][ui_value]/2.);
                        p = 
                        cy.$('#f'+edge_counter).data('label', pct);
                        if(i == 0) flow += flow_data[edge_counter][ui_value];
                    }
                }

        
            var t = 2*(ui_value / graph_data[0].length)-1;
            t = Math.round(t*100)/100;
            $( "#time" ).val(t);
            $( "#flow" ).val(flow);
};

update_graph(0);

$( function() {
    $( "#slider-range-min" ).slider({
        range: "min",
        value: 0,
        min: 0,
        max: graph_data[0].length-1,
        slide: function( event, ui ) {
            update_graph(ui.value);
        }
    });

} );

// Plot
function zip(arrays) {
    return arrays[0].map(function(_,i){
        return arrays.map(function(array){return array[i]});
    });
}

y = graph_data[1];
x = Array.apply(null, y).map(function (_, i) {return 2*i/y.length-1;});
zipxy = zip([x, y]);

$('#plot-button').click(function() {
    i = node_names.indexOf(($("#source").val()));
    j = node_names.indexOf(($("#target").val()));
    y = graph_data[i*n_nodes+j];
    y2 = flow_data[i*n_nodes+j];
    x = Array.apply(null, y).map(function (_, i) {return 2*i/y.length-1;});
    zipxy = zip([x, y]);
    zipxy2 = zip([x, y2]);
    $.plot($("#flot-placeholder"), [ zipxy, zipxy2 ]);
    //$.plot($("#flot-placeholder"), [ zipxy2 ]);
});

$(document).ready(function () {
    $.plot($("#flot-placeholder"), [ zipxy ]);
});
