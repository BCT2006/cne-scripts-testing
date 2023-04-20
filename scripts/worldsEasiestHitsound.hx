function onPlayerHit(a)
    if (!a.note.isSustainNote)
      FlxG.sound.play(Paths.sound('hitsound'), 0.5);