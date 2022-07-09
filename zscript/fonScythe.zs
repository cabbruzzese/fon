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

const SCYTHERANGE=155.0;
class fonScythe : fonMeleeWeapon replaces HNecroWeaponScythe
{
	int swingcount;
	Default
	{
		//$Title Scythe
		Tag "$TAG_Scythe";
		Inventory.PickupMessage "$PKUP_Scythe";
        Weapon.AmmoType "";
		Weapon.AmmoType2 "HNecroWeaponScytheAmmo";
		Weapon.AmmoUse2 1;
		Weapon.AmmoGive2 8;
		XScale 0.5;
		YScale (0.5 / 1.2);
		+WEAPON.NOALERT
	}
	States
	{
	Spawn:
		PSCY A -1 Light("SCYTHEAMMO2");
		Stop;
	Select:
		SCYT A 1 A_Raise;
		Loop;
	Deselect:
		SCYT A 1 A_Lower;
		Loop;
	Ready:
		SCYT A 1 A_WeaponReady;
		Loop;
    Fire:
		TNT1 A 4 A_HoNScytheCheckAttackMelee;
		SCYT B 4;
		SCYT C 3;
		SCYT D 3 A_FonMeleeWeaponStrike(SCYTHERANGE, 1, 55, false, false);
		SCYT E 3;
		TNT1 A 11;
		TNT1 A 0 A_HoNScytheRefire;
		Goto Ready;
	HorizontalMelee:
		TNT1 A 4 A_WeaponOffset(120,0,WOF_KEEPY|WOF_INTERPOLATE);
		SCYT F 3;
		SCYT I 3 A_WeaponOffset(-20,0,WOF_KEEPY|WOF_ADD);
		SCYT G 2 A_WeaponOffset(-20,0,WOF_KEEPY|WOF_ADD);
		SCYT G 2
		{
			A_WeaponOffset(-80,10,WOF_ADD);
			A_FonMeleeWeaponStrike(SCYTHERANGE, 1, 55, true, false);
		}
		SCYT HH 2 A_WeaponOffset(-100,20,WOF_ADD);
		TNT1 A 8 A_WeaponOffset(0,32);
		TNT1 A 0 A_HoNScytheRefire;
		Goto Ready;
	AltFire:
		TNT1 A 4 A_HoNScytheCheckAttack;
		SCYT B 4;
		SCYT C 3;
		SCYT D 3 A_HoNScytheStrike;
		SCYT E 3;
		TNT1 A 11;
		TNT1 A 0 A_HoNScytheRefire;
		Goto Ready;
	Horizontal:
		TNT1 A 4 A_WeaponOffset(120,0,WOF_KEEPY|WOF_INTERPOLATE);
		SCYT F 3;
		SCYT I 3 A_WeaponOffset(-20,0,WOF_KEEPY|WOF_ADD);
		SCYT G 2 A_WeaponOffset(-20,0,WOF_KEEPY|WOF_ADD);
		SCYT G 2
		{
			A_WeaponOffset(-80,10,WOF_ADD);
			A_HoNScytheStrike(true);
		}
		SCYT HH 2 A_WeaponOffset(-100,20,WOF_ADD);
		TNT1 A 8 A_WeaponOffset(0,32);
		TNT1 A 0 A_HoNScytheRefire;
		Goto Ready;
	}

	action void A_HoNScytheCheckAttack()
	{
		if(!player)
			return;
		Weapon w = player.ReadyWeapon;

        if (w.ammo2.Amount < 1)
            player.SetPsprite(PSP_WEAPON, w.FindState("Fire"));

		if(invoker.swingcount >= 2)
		{
			invoker.swingcount = -1;
			player.SetPsprite(PSP_WEAPON, w.FindState("Horizontal"));
		}
	}

    action void A_HoNScytheCheckAttackMelee()
	{
		if(!player)
			return;
		Weapon w = player.ReadyWeapon;

		if(invoker.swingcount >= 2)
		{
			invoker.swingcount = -1;
			player.SetPsprite(PSP_WEAPON, w.FindState("HorizontalMelee"));
		}
	}

	action void A_HoNScytheStrike(bool horiz = false)
	{
		A_StartSound("weapons/scythe/swing", CHAN_WEAPON);
		A_FireProjectile(horiz ? "fonScytheWaveHoriz" : "fonScytheWave", spawnheight: 6);

        if(!player)
			return;
		let fp = fonPlayer.GetPlayerOrMorph(player.mo);
		if (!fp)
			return;

        int magic = fp.GetMagic();
        if (magic >= SCYTHE_LEVEL_RAISE)
        {            
            //HNecroGlobal.A_HoNGolemQuake(fp, 0, 0, 384);
			fp.A_SpawnItemEx("HON_StoneGolemShockwave", 0, 8, 1);
            let rd = A_RadiusGive("RaiseDeadItem", 256, RGF_CORPSES);
        }
	}

	action void A_HoNScytheRefire()
	{
		let player = player;
		if(!player)
			return;
		bool pending = player.PendingWeapon != WP_NOCHANGE && (player.WeaponState & WF_REFIRESWITCHOK);
		if((player.cmd.buttons & BT_ATTACK)
			&& !player.ReadyWeapon.bAltFire && !pending && player.health > 0)
		{
			invoker.swingcount++;
			player.refire++;
			player.mo.FireWeapon(null);
		}
		else
		{
			invoker.swingcount = 0;
			player.refire = 0;
			player.ReadyWeapon.CheckAmmo(player.ReadyWeapon.bAltFire? Weapon.AltFire : Weapon.PrimaryFire, true);
		}
	}
}

class fonScytheShockwave : actor
{
	Default
	{
		+NOBLOCKMAP
		+NOTELEPORT
		+NOGRAVITY
		+DONTTRANSLATE
		+DONTSPLASH
		RenderStyle "Translucent";
		Alpha 0.8;
	}
	States
	{
	Spawn:
		0000 ABCDEFGHIJKLM 2;
		Stop;
	}
}

class fonScytheWaveHoriz : HNecroWeaponScytheWaveHoriz
{
	Default
	{
		-HARMFRIENDS
	}

    Array<Actor> targs;
	override int DoSpecialDamage (Actor victim, int damage, Name damagetype)
	{
		let vic = victim;
		//if vic is in the array already, skip him
		if(targs.find(vic) < targs.size())
			return -1;
        
        //Don't harm friendlies
        if (vic.bFriendly)
            return -1;

		targs.push(vic);
		A_StartSound("weapons/scythe/hit");
		damage = random(30, 35);
		vic.SpawnBlood(pos, frandom(0, 360), damage);
		HNecroGlobal.HoNBurningFlame(target, vic, true);
		return damage;
	}
}

class fonScytheWave : fonScytheWaveHoriz
{
	override void PostBeginPlay()
	{
		A_SetRoll(45);
		Super.PostBeginPlay();
	}
	Default
	{
		Radius 13;
		Height 13;
	}
}