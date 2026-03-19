# Ludo Game Blueprint

## Overview

This document outlines the plan and progress for creating a Ludo game application using Flutter and Firebase. The application will allow users to play Ludo with friends online.

## Style, Design, and Features

### Initial Version

*   **Authentication:**
    *   Users can sign in with Google.
    *   Users can play as a guest (anonymous sign-in).
*   **Theme:**
    *   Light and dark themes are implemented using `provider`.
    *   Custom fonts are used with the `google_fonts` package.
*   **Routing:**
    *   Navigation is handled by `go_router`.
    *   The initial route is the login screen.
*   **Structure:**
    *   The project follows a feature-first structure.
    *   Services are separated from the UI.

### Implemented

*   **Lobby System:**
    *   Users can create a new game room, which generates a unique room code.
    *   Users can join an existing game room using a room code.
    *   A waiting room is implemented where players can gather before the game starts.
    *   Players can toggle their ready status.
    *   Real-time updates for the lobby and waiting room are handled by Firebase Realtime Database.

### Current Plan

*   **Game Implementation:**
    *   Create the Ludo game board UI.
    *   Implement the core game logic, including dice rolls, token movement, and game rules.
    *   Use Firebase Realtime Database to synchronize the game state in real-time.
    *   Implement a turn-based system.
*   **Random Matchmaking:**
    *   Create a system for matching random players together.
