{ ... }:

{
    services.mako = {
        enable = true;

        settings = {
            default-timeout = 2000;

            "mode=do-not-disturb" = {
                invisible = true;
                on-notify = "none";
            };

            "mode=silent" = {
                on-notify = "none";
            };
        };
    };
}
