name = "打架小木牌"
description = ""
author = "封锁/辣椒小皇紙"
version = "1.1.0"

forumthread = ""

api_version = 10

all_clients_require_mod = false
client_only_mod = false
dst_compatible = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = {"打架小木牌"}

----------------------
-- General settings --
----------------------

configuration_options =
{
    {
        name = "finiteuses",
        label = "FiniteUses",
        hover = "",
        options =   {
                        {description = "1", data = 1, hover = ""},
                        {description = "2", data = 2, hover = ""},
                        {description = "3", data = 3, hover = ""},
                        {description = "4", data = 4, hover = ""},
                        {description = "5", data = 5, hover = ""},
                        {description = "6", data = 6, hover = ""},
                        {description = "7", data = 7, hover = ""},
                        {description = "8", data = 8, hover = ""},
                        {description = "9", data = 9, hover = ""},
                        {description = "10", data = 10, hover = ""},
                    },
        default = 5,
    },
}