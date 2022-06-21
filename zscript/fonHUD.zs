class fonHUD : HNecroHUD
{
    HUDFont mHUDFontStats;
    override void Init(void)
	{
        Super.Init();

		Font fnt = "BIGFONT";
		mHUDFontStats = HUDFont.Create(fnt, 0, Mono_Off);
	}

    override void Draw(int state, double TicFrac)
	{
		Super.Draw(state, TicFrac);
        
		if (state == HUD_StatusBar)
		{
            if (automapactive)
                DrawRPGStats();

            DrawXPBar();
		}
        
	}

    protected void DrawXPBar()
    {
        let fonPlayer = fonPlayer(CPlayer.mo);
		if (!fonPlayer)
			return;

        let statItem = fonPlayer.GetUIStats();
		if (!statItem)
			return;

        Vector2 imgcoord = (152, 398);
        double scaleWidth = double(statItem.Exp) / double(statItem.ExpNext);
        int width = 672 * scaleWidth;

        DrawImage("graphics/XPBAR.png", imgcoord, DI_FORCESCALE|DI_ITEM_OFFSETS, 1.0, (width, 1.0), (width, 1.0));
    }

    protected void DrawRPGStats ()
	{
        let xPos = 150;
		let yPos = 260;
		let yStep = 20;
		
		let xPosStats = 500;

		let fonPlayer = fonPlayer(CPlayer.mo);
		if (!fonPlayer)
			return;

		let statItem = fonPlayer.GetUIStats();
		if (!statItem)
			return;

		let text1 = String.Format("XP: %s / %s", FormatNumber(statItem.Exp, 0), FormatNumber(statItem.ExpNext, 0));
		let text2 = String.Format("Level: %s", FormatNumber(statItem.ExpLevel, 0));
				
		//Exp
		DrawString(mHUDFontStats, text1, (xPos, yPos), DI_TEXT_ALIGN_LEFT);
		DrawString(mHUDFontStats, text2, (xPos, yPos + yStep), DI_TEXT_ALIGN_LEFT);
		
		let statText1 = String.Format("Strength: %s", FormatNumber(statItem.Strength, 0));
		let statText2 = String.Format("Armor: %s", FormatNumber(statItem.Dexterity, 0));
		let statText3 = String.Format("Magic: %s", FormatNumber(statItem.Magic, 0));

		//Stats
		DrawString(mHUDFontStats, statText1, (xPosStats, yPos - yStep), DI_TEXT_ALIGN_RIGHT);
		DrawString(mHUDFontStats, statText2, (xPosStats, yPos), DI_TEXT_ALIGN_RIGHT);
		DrawString(mHUDFontStats, statText3, (xPosStats, yPos + yStep), DI_TEXT_ALIGN_RIGHT);
	}
}