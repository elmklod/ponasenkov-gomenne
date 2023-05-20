game = {}

function game:initialize(world, sounds)
    self.sounds = sounds
    self.state = "menu"
    self.world = world
    self.highscore = 0
    self.name = "Bastard Busting 3000"
    self.sounds[self.state]:play()
end

function game:changeState(state)
    self.sounds[self.state]:stop()
    self.state = state
    while self.sounds["bullet_shot"]:isPlaying() or self.sounds["bullet_hit"]:isPlaying() or self.sounds["character_jump"]:isPlaying() or self.sounds["enemy_killed"]:isPlaying() or self.sounds["character_killed"]:isPlaying() or self.sounds["button_push"]:isPlaying() do
    end
    self.sounds[self.state]:play()
end