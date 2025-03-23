({
    myAction : function(component, event, helper) {

    },
    startGame : function(component, event, helper) {
        // Initialize or reshuffle the board
        helper.initializeBoard(component);
    },
    handleGameModeChange : function(component, event, helper) {
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
    },
    startNewGame: function(component, event, helper) {
        // Reset game state and start a new game
        var gameMode = component.find("gameMode").get("v.value");
        // Initialize a new game board
        helper.initializeBoard(component);
        
        // Fire application event or call helper method to start a new game
        var startGameEvent = $A.get("e.c:GameStartEvent");
        if (startGameEvent) {
            startGameEvent.setParams({
                "gameMode": gameMode,
                "isNewGame": true
            });
            startGameEvent.fire();
        }
    }
})