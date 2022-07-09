//-----------------------------------------------------------------------------
// Code modified by from HON for Feat of Necromancy Mod. Original license below
//                      - peewee
//-----------------------------------------------------------------------------
//
// Copyright 2019-2022 HON Team, Frechou Games
// Copyright 1993-2022 GZDoom Team, id Software, and contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/
//
//-----------------------------------------------------------------------------

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
        let fonPlayer = fonPlayer.GetPlayerOrMorphUI(CPlayer.mo);
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

		let fonPlayer = fonPlayer.GetPlayerOrMorphUI(CPlayer.mo);
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
		
		let statText1 = String.Format("Vengeance: %s", FormatNumber(statItem.Strength, 0));
		let statText2 = String.Format("Ferocity: %s", FormatNumber(statItem.Dexterity, 0));
		let statText3 = String.Format("Scorn: %s", FormatNumber(statItem.Magic, 0));

		//Stats
		DrawString(mHUDFontStats, statText1, (xPosStats, yPos - yStep), DI_TEXT_ALIGN_RIGHT);
		DrawString(mHUDFontStats, statText2, (xPosStats, yPos), DI_TEXT_ALIGN_RIGHT);
		DrawString(mHUDFontStats, statText3, (xPosStats, yPos + yStep), DI_TEXT_ALIGN_RIGHT);
	}
}