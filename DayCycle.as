// used for the game's day / night cycle

void onInit(CMap@ this){
    this.SetDayTime(.5); // set mid day
}

void onInit(CRules@ this)
{
    // time grace period of 10 minutes
    this.set_f32("time grace period", (30*60*10));
    this.set_bool("graceperiod", true); // doesnt work on cmap init
}

void onTick(CRules@ rules) // this doesnt run on tick in gamemode.cfg?
{
    CMap@ this = getMap();
    if(this is null){ return; }
    uint time = getGameTime();

    bool graceperiod = rules.get_bool("graceperiod");
    f32 gracetime = rules.get_f32("time grace period");

    // grace period
    if(graceperiod){
        if(time <= gracetime){
            if(getGameTime() % (30*10) == 0){ // prevent spam
                print("Time tried to tick but grace period prevented it.");
            }
            return;
        }
    }

    f32 subtime;
    if(graceperiod){
        subtime = gracetime;
    }
    else{ subtime = 0; }

    if(int(time - subtime) % (60*30) == 0){ // 1800 ticks, 60 sec / 1 minute
        bool cansettime = (this.getDayTime() - 0.01) < 0 ? false : true; // is day going to need to be reset to 1?
        f32 settime;
        if(cansettime){
            settime = this.getDayTime() - 0.01;
        }
        else{
            settime = 1.0;
        }
        this.SetDayTime(settime);
        print("Time ticked to: " + this.getDayTime());
    }
}