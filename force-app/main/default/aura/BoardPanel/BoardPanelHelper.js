({
    helperMethod : function() {

    },
    initializeBoard: function(component) {
        // Get the board size
        var size = component.get("v.boardSize");
        
        // If a game mode is selected, update the columnClass accordingly
        if (size === 3) {
            component.set("v.columnClass", "slds-size_1-of-3");
        } else if (size === 4) {
            component.set("v.columnClass", "slds-size_1-of-4");
        } else if (size === 6) {
            component.set("v.columnClass", "slds-size_1-of-6");
        }
        
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