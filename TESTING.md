# Testing World 3 No Level Cap

For people and agents who test the mod in the game. Check `logs\rqmod.log` for
`Loading world3-no-cap` first.

## What it adds

- **A page in Config's Mods tab**, **World 3 No Level Cap** (`rq.config.settings`, kept in the
  save). In `rqmod-ctl ui`, on that page: `check-on` (No level cap in World 3) and `button-reset`.
  Before a save is loaded the page asks for one.

No other `rq.agent.control` ids. Do not invent controls for it.

## How to check it

1. In World 3, with a character at their cap (the status page shows `LV 60 / 60`): the status page
   and the cards show ∞ as Rance's, and a fight won gives that character EXP and levels.
2. In World 1 or 2, the same character: the game's cap again (`LV 61 / 60`), no EXP.
3. Athena 2.0 (number 27) stays at LV 1 everywhere.
4. A Forbidden Talent worn in World 3 raises the character's own cap (seen back in World 1 or 2, or
   with the box off).

## Forcing it for a test

`rq.mod.get("world3-no-cap")` returns `active()` (World 3, a save loaded, the box on), `lifted(iic)`
(the caps lifted for that character now), `get(key)` and `set(key, value)` for the page's key `on`,
and `cap` (999, Rance's). Put back what you set: the box stays in the save. The Lab's
`t.world(3)` sets the world for what reads it, which is all the mod reads.

## Tested in the game

The Test Lab's scenario `world3-no-cap`: the cap read in each world and with the box off, ∞, EXP and
levels past the cap from a fight and from `rq.chara.add_exp`, Athena 2.0, a Forbidden Talent's
raise, the page.
