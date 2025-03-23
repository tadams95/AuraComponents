({
    doInit: function(component, event, helper) {
        // Setup placeholder for the board
        helper.setupPlaceholders(component);
    },
    
    startNewGame: function(component, event, helper) {
        helper.initializeGame(component);
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
    }
})