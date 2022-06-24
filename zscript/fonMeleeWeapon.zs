//===========================================================================
//
// fonSword
//
//===========================================================================
class fonMeleeWeapon : HNecroWeaponSword
{
	Default
	{
		Weapon.AmmoType "HNecroWeaponSwordAmmo";
		Weapon.AmmoUse 1;
		+WEAPON.AMMO_OPTIONAL
		+WEAPON.NOALERT
	}

	action void A_FonMeleeWeaponStrike(int meleeRange, int damageMax = 20, int damageMin = 1, bool horizontal = false)
	{
		if(!player)
			return;
		let fp = fonPlayer(player.mo);
		if (!fp)
			return;

		FTranslatedLineTarget t;
		int damage = random(damageMin, damageMax) + fp.GetStrength();
		let w = player.ReadyWeapon;
		class<Actor> pufftype = horizontal ? "HNecroWeaponSwordPuffHoriz" : "HNecroWeaponSwordPuff";
		int useammo;
		if((useammo = (w.Ammo1 && w.Ammo1.Amount > 0)))
		{
			damage += fp.GetMagic() * 2;
			pufftype = horizontal ? "HNecroWeaponSwordPuffGlowHoriz" : "HNecroWeaponSwordPuffGlow";
		}
		for(int i = 0; i < 16; i++)
		{
			for(int j = 1; j >= -1; j -= 2)
			{
                //string msg = String.Format("Range: %d", meleeRange);
                //A_PrintBold(msg);
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