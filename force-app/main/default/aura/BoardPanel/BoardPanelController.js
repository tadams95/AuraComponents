({
    doInit: function(component, event, helper) {
        // Initialize the game when component loads
        helper.initializeBoard(component);
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
        if (!component.get("v.gameActive")) return;
        
        var clickedElement = event.currentTarget;
        var rowIndex = parseInt(clickedElement.dataset.row);
        var colIndex = parseInt(clickedElement.dataset.col);
        
        helper.toggleTileSelection(component, rowIndex, colIndex);
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
        console.log('Starting new game');
        
        // First clear any existing timer
        helper.clearGameTimer(component);
        
        // Reset game state and start a new game
        component.set("v.score", 0);
        component.set("v.timeRemaining", 60); // Reset to 60 seconds
        console.log('Time remaining set to 60');
        
        component.set("v.gameActive", true);
        component.set("v.selectedWord", "");
        component.set("v.isWordTooShort", true);
        component.set("v.timerClass", "slds-text-color_default");
        component.set("v.submittedWords", []);
        component.set("v.duplicateWordError", false);
        
        var gameMode = component.find("gameMode").get("v.value");
        
        // Initialize a new game board
        helper.initializeBoard(component);
        
        // Ensure the DOM is updated before starting timer
        setTimeout(function() {
            // Start timer AFTER all state is reset and DOM is updated
            helper.startGameTimer(component);
        }, 100);
        
        // Fire application event or call helper method to start a new game
        var startGameEvent = $A.get("e.c:GameStartEvent");
        if (startGameEvent) {
            startGameEvent.setParams({
                "gameMode": gameMode,
                "isNewGame": true
            });
            startGameEvent.fire();
        }
    },
    
    handleSelectedWordChange: function(component, event, helper) {
        var selectedWord = component.get("v.selectedWord");
        var isWordTooShort = selectedWord.length < 3;
        component.set("v.isWordTooShort", isWordTooShort);
    }
})