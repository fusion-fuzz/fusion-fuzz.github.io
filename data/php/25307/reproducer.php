<?php
session_set_save_handler(new SessionHandler(), true);
ini_set("session.save_handler", "files");
session_start();
(new SessionHandler)->open("", "");
