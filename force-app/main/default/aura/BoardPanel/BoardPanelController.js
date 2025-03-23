({
    doInit: function(component, event, helper) {
        // Setup placeholder for the board
        helper.setupPlaceholders(component);
    },
    
    myAction: function(component, event, helper) {
        // Empty placeholder method
    },
    
    startGame: function(component, event, helper) {
        // Initialize or reshuffle the board
        helper.initializeBoard(component);
    },
    
    handleGameModeChange: function(component, event, helper) {
        // Get the selected value
        var selectedValue = event.getParam("value");
        var newSize = 4; // default to medium
        var columnClass = "slds-size_1-of-4"; // default to 4 columns
        
        // Update board size based on game mode
        if(selectedValue === "easy") {
            newSize = 3;
            columnClass = "slds-size_1-of-3";
        } else if(selectedValue === "medium") {
            newSize = 4;
            columnClass = "slds-size_1-of-4";
        } else if(selectedValue === "hard") {
            newSize = 6;
            columnClass = "slds-size_1-of-6";
        }
        
        // Update component attributes
        component.set("v.boardSize", newSize);
        component.set("v.columnClass", columnClass);
        
        // Update placeholder arrays for the empty grid
        var placeholderRows = [];
        var placeholderCols = [];
        for(var i = 0; i < newSize; i++) {
            placeholderRows.push(i);
            placeholderCols.push(i);
        }
        component.set("v.placeholderRows", placeholderRows);
        component.set("v.placeholderCols", placeholderCols);
        
        // Check if game is active
        var gameActive = component.get("v.gameActive");
        
        // If game is not active, refresh the board immediately
        if (!gameActive) {
            helper.initializeBoard(component);
        } else {
            // If game is active, show a toast notification that board will update on next game
            var toastEvent = $A.get("e.force:showToast");
            if (toastEvent) {
                toastEvent.setParams({
                    title: "Game Mode Changed",
                    message: "The new game mode will take effect when you start a new game or reshuffle.",
                    type: "info",
                    duration: 4000
                });
                toastEvent.fire();
            }
        }
    },
    
    handleTileClick: function(component, event, helper) {
        // Only process clicks if the game is active and not over
        if (!component.get("v.gameActive") || component.get("v.gameOver")) {
            return;
        }
        
        var clickedElement = event.currentTarget;
        var rowIndex = parseInt(clickedElement.dataset.row, 10);
        var colIndex = parseInt(clickedElement.dataset.col, 10);
        var clickedWord = clickedElement.dataset.word;
        
        // Check if this tile is already revealed
        var board = component.get("v.board");
        if (board[rowIndex][colIndex].revealed) {
            return; // Tile already revealed, do nothing
        }
        
        // Mark this tile as revealed
        board[rowIndex][colIndex].revealed = true;
        component.set("v.board", board);
        
        // Track revealed tiles
        var revealedTiles = component.get("v.revealedTiles") || [];
        revealedTiles.push({row: rowIndex, col: colIndex});
        component.set("v.revealedTiles", revealedTiles);
        
        // Check if the clicked word matches the correct word
        var correctWord = component.get("v.correctWord");
        if (clickedWord === correctWord) {
            // Player found the correct word
            helper.handleCorrectWord(component);
        } else {
            // Wrong guess
            helper.handleWrongGuess(component);
        }
    },
    
    submitWord: function(component, event, helper) {
        helper.validateAndScoreWord(component);
    },
    
    updateBoardNow: function(component, event, helper) {
        // Reset word selection
        component.set("v.selectedWord", "");
        component.set("v.isWordTooShort", true);
        
        // Initialize new board with current settings
        helper.initializeBoard(component);
        
        // Show confirmation toast
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                title: "Board Updated",
                message: "Game board has been updated to the new size.",
                type: "success",
                duration: 2000
            });
            toastEvent.fire();
        }
    },
    
    startNewGame: function(component, event, helper) {
        helper.initializeGame(component);
    },
    
    handleSelectedWordChange: function(component, event, helper) {
        var selectedWord = component.get("v.selectedWord");
        var isWordTooShort = selectedWord.length < 3;
        component.set("v.isWordTooShort", isWordTooShort);
    }
})