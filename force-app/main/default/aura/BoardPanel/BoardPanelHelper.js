({
    helperMethod : function() {

    },
    initializeBoard: function(component) {
        // Get the board size
        var size = component.get("v.boardSize");
        
        // Sample letters for demonstration
        var letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        
        // Create a 2D array for the board
        var board = [];
        for(var i = 0; i < size; i++) {
            var row = [];
            for(var j = 0; j < size; j++) {
                // Generate a random letter
                var randomIndex = Math.floor(Math.random() * letters.length);
                var letter = letters.charAt(randomIndex);
                
                // Create a cell object
                row.push({
                    letter: letter,
                    rowIndex: i,
                    colIndex: j,
                    selected: false
                });
            }
            board.push(row);
        }
        
        // Set the board attribute
        component.set("v.board", board);
    }
})