--  https://github.com/zlbruce/dotconfig/blob/master/.xmobarrc

Config {
        position = TopP 0 276,
         -- font = "xft:WenQuanYi Zen Hei Mono-12",
        font = "xft:CaskaydiaCove Nerd Font Mono-12",
        bgColor = "black",
        -- fgColor = "grey",
        fgColor = "#ffffff",
        -- , position = TopSize L 90 25,
        lowerOnStart = False,
        overrideRedirect = False,
        allDesktops = False,
        persistent = True,
        commands = [
             Run Weather "ZGGG" ["-t","<tempC>C","-L","18","-H","25","--normal","green","--high","red","--low","lightblue"] 36000,
             Run Network "wlp59s0" ["-t","直:<rx>KB <tx>KB", "-L","10","-H","200","-n","green","-h","red","-l","#CEFFAC"] 10,

             -- Run Cpu ["-L","3","-H","50","--normal","green","--high","red","-t","C: <total>%"] 10,
             Run MultiCpu ["-t","CPU:<total>%","-L","30","-H","60","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC","-w","3"] 10,
             Run Memory ["-t","Mem: <usedratio>%","-H","8192","-L","4096","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC"] 10,
             Run Swap ["-t","Swap: <usedratio>%","-H","1024","-L","512","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC"] 10,
             -- Run PipeReader "/dev/shm/lrcfifo" "lrc",
             -- Run Com "uname" ["-s","-r"] "" 36000,
             -- Run Com "eyerest-cli" ["-t","%M:%S"] "eyerest" 10,
             -- Run Date "%a %_m-%_d %H:%M" "date" 10,
             Run Date "%Y-%m-%d %a %H:%M:%S" "date" 10,
             -- Run Volume "default" "Master" ["-t", "🔊<volume>% <status>"] 10,
             Run StdinReader
        ],
        sepChar = "%",
        alignSep = "}{",
        template = "%StdinReader% }{ %multicpu% | %memory% | %swap% | %wlp59s0% | :<fc=#ee9a00>%date%</fc> | %ZGGG% | %default:Master%"
}
