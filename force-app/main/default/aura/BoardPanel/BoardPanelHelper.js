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
    },
    
    toggleTileSelection: function(component, rowIndex, colIndex) {
        var board = component.get("v.board");
        var cell = board[rowIndex][colIndex];
        
        // Toggle selection state
        cell.selected = !cell.selected;
        
        // Update the board
        component.set("v.board", board);
        
        // Update selected word display
        this.updateSelectedWord(component);
    },
    
    updateSelectedWord: function(component) {
        var board = component.get("v.board");
        var selectedWord = "";
        
        // Collect selected letters
        for(var i = 0; i < board.length; i++) {
            for(var j = 0; j < board[i].length; j++) {
                if(board[i][j].selected) {
                    selectedWord += board[i][j].letter;
                }
            }
        }
        
        component.set("v.selectedWord", selectedWord);
    },
    
    validateAndScoreWord: function(component) {
        var selectedWord = component.get("v.selectedWord");
        if(selectedWord.length < 3) {
            component.set("v.isWordTooShort", true);
            return;
        }
        
        // In a real implementation, you'd validate against a dictionary
        // For this example, we'll just score based on word length
        var score = component.get("v.score");
        score += (selectedWord.length * 10);
        component.set("v.score", score);
        
        // Clear selections
        var board = component.get("v.board");
        for(var i = 0; i < board.length; i++) {
            for(var j = 0; j < board[i].length; j++) {
                board[i][j].selected = false;
            }
        }
        component.set("v.board", board);
        component.set("v.selectedWord", "");
        component.set("v.isWordTooShort", true);
    },
    
    startGameTimer: function(component) {
        // Clear any existing timer
        this.clearGameTimer(component);
        
        // Reset timer class
        component.set("v.timerClass", "slds-text-color_default");
        
        var that = this; // Store reference to helper
        
        // Set up timer
        var gameTimerId = setInterval($A.getCallback(function() {
            var timeRemaining = component.get("v.timeRemaining");
            timeRemaining--;
            
            // Update timer class when time is running low
            if (timeRemaining <= 10) {
                component.set("v.timerClass", "slds-text-color_error");
            }
            
            component.set("v.timeRemaining", timeRemaining);
            
            if(timeRemaining <= 0) {
                // Game over
                component.set("v.gameActive", false);
                that.clearGameTimer(component);
                that.showGameOverMessage(component);
            }
        }), 1000);
        
        // Store timer ID for later cleanup
        component.set("v.gameTimerId", gameTimerId);
    },
    
    clearGameTimer: function(component) {
        var gameTimerId = component.get("v.gameTimerId");
        if(gameTimerId) {
            clearInterval(gameTimerId);
        }
    },
    
    showGameOverMessage: function(component) {
        // Show game over toast and final score
        var score = component.get("v.score");
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent) {
            toastEvent.setParams({
                title: "Game Over!",
                message: "Your final score is: " + score,
                type: "info",
                duration: 5000
            });
            toastEvent.fire();
        }
    }
})