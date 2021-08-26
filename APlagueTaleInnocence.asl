// Contains functionality for load removal, autostart, and autosplitting.

state("APlagueTaleInnocence_x64", "Steam")
{
    bool     Loading       : "WwiseLibPCx64R.dll", 0x262521;
    int      PlayerControl : 0x152E91C;
    string50 MapName       : 0x15206E0, 0x88, 0x0, 0xD0, 0x990, 0x260;
}

state("APlagueTaleInnocence_x64", "Epic")
{
    bool     Loading       : "WwiseLibPCx64R.dll", 0x262521;
    int      PlayerControl : 0x152E6DC;
    string50 MapName       : 0x16AADC0, 0x10, 0x110, 0xD8, 0x10, 0x30, 0x170, 0x260;
}

state("APlagueTaleInnocence_x64", "Xbox")
{
    bool     Loading       : "WwiseLibPCx64R.dll", 0x262521;
    int      PlayerControl : 0x1744EBC;
    string50 MapName       : "MessageBus.dll", 0x5C0DE0, 0x340, 0x668;
}

startup
{
    var Chapters = new Dictionary<string,string>
    {
        // { "DOMAIN",           "Chapter 1 - The de Rune Legacy" },
        { "VILLAGE",          "Chapter 2 - The Strangers" },
        { "VILLAGE2",         "Chapter 3 - Retribution" },
        { "FARM",             "Chapter 4 - The Apprentice" },
        { "BATTLEFIELD",      "Chapter 5 - The Ravens' Spoils" },
        { "BATTLEFIELD2",     "Chapter 6 - Damaged Goods" },
        { "SHELTER_FOREST",   "Chapter 7 - The Path Before Us" },
        { "SHELTER_MORNING",  "Chapter 8 - Our Home" },
        { "UNIVERSITY",       "Chapter 9 - In the Shadow of Ramparts" },
        { "UNIVERSITY2",      "Chapter 10 - The Way of Roses" },
        { "SHELTER_SAFE",     "Chapter 11 - Alive" },
        { "CORRUPTED_DOMAIN", "Chapter 12 - All That Remains" },
        { "ILLUSION",         "Chapter 13 - Penance" },
        { "INQUISITION",      "Chapter 14 - Blood Ties" },
        { "SHELTER_SIEGE",    "Chapter 15 - Remembrance" },
        { "CATHEDRAL",        "Chapter 16 - Coronation" },
        { "EPILOGUE",         "Chapter 17 - For Each Other" }
    };

    foreach (var chapter in Chapters)
        settings.Add(chapter.Key, true, chapter.Value);

    vars.OnStart = (EventHandler)((s, e) => vars.DoneMaps = new List<string> { current.Map });
    timer.OnStart += vars.OnStart;

    if (timer.CurrentTimingMethod == TimingMethod.RealTime)
    {
        var timingMessage = MessageBox.Show (
            "Removing loads from A Plague Tale: Innocence requires comparing against Game Time.\n" +
            "Would you like to switch to it?",
            "LiveSplit | A Plague Tale: Innocence",
            MessageBoxButtons.YesNo);

        if (timingMessage == DialogResult.Yes)
            timer.CurrentTimingMethod = TimingMethod.GameTime;
    }
}

init
{
    switch (game.MainModule.ModuleMemorySize)
    {
        case 0x184B000: version = "Steam"; break;
        case 0x181D000: version = "Epic"; break;
        case 0x1A4A000: version = "Xbox"; break;
        default: version = "Unknown!"; break;
    }

    current.Map = "";
    vars.DoneMaps = new List<string>();
}

update
{
    if (version == "Unknown!") return false;

    current.Map = current.MapName.Split('>')[1];

    // DEBUG CODE
    // print(current.Loading.ToString());
    // print(current.MapName.Split('>')[1].ToString());
}

start
{
    return current.MapName.Contains("DOMAIN") && current.PlayerControl == 4024 && old.PlayerControl == 4025;
}

split
{
    if (settings[current.Map] && !vars.DoneMaps.Contains(current.Map))
    {
        vars.DoneMaps.Add(current.Map);
        return true;
    }
}

isLoading
{
    return current.Loading;
}

exit
{
    timer.IsGameTimePaused = true;
}

shutdown
{
    timer.OnStart -= vars.OnStart;
}
