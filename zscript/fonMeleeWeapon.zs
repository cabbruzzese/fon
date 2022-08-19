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

class fonMeleeWeapon : HNecroWeaponSword
{
	Default
	{
		Weapon.AmmoType "HNecroWeaponSwordAmmo";
		Weapon.AmmoUse 1;
		+WEAPON.AMMO_OPTIONAL
		+WEAPON.NOALERT
	}

	action void A_FonMeleeWeaponStrike(int meleeRange, int damageMin = 1, int damageMax = 20, bool horizontal = false, bool usesAmmo = true)
	{
		if(!player)
			return;
		let fp = fonPlayer.GetPlayerOrMorph(player.mo);
		if (!fp)
			return;

		FTranslatedLineTarget t;
		int damage = random(damageMin, damageMax) + fp.GetStrength();
		let w = player.ReadyWeapon;
		class<Actor> pufftype = horizontal ? "HNecroWeaponSwordPuffHoriz" : "HNecroWeaponSwordPuff";
		int useammo;
		if(usesAmmo && (useammo = (w.Ammo1 && w.Ammo1.Amount > 0)))
		{
			damage += fp.GetMagic() * 0.5;
			pufftype = horizontal ? "HNecroWeaponSwordPuffGlowHoriz" : "HNecroWeaponSwordPuffGlow";
		}
		for(int i = 0; i < 16; i++)
		{
			for(int j = 1; j >= -1; j -= 2)
			{
				double ang = angle + j * i * (45. / 16);
				let slope = AimLineAttack(ang, meleeRange, t);
				if(t.linetarget)
				{
					LineAttack(ang, meleeRange, slope, damage, 'Melee', pufftype, true, t);
					if(t.linetarget && !(t.linetarget is 'HoN_GolemWall'))
					{
						AdjustPlayerAngle(t);
						w.DepleteAmmo(w.bAltFire, false);
						return;
					}
				}
			}
		}
		let slope = AimLineAttack(angle, meleeRange);
		LineAttack(angle, meleeRange, slope, damage, 'Melee', pufftype, true);
	}
}