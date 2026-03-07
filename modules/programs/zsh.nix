{ ... }:

{
    programs.zsh = {
        enable = true;
        enableCompletion = true;
        history.ignoreAllDups = true;

        oh-my-zsh = {
            enable = true;
            theme = "lambda";
        };

        syntaxHighlighting.enable = true;
    };
}
