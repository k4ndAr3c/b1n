#!/usr/bin/env python3
import psutil
from time import sleep

save_sent = psutil.net_io_counters().bytes_sent
save_recv = psutil.net_io_counters().bytes_recv
sleep(1)
val_sent = psutil.net_io_counters().bytes_sent
val_recv = psutil.net_io_counters().bytes_recv
print(f"⇓ {(val_recv-save_recv)//1024} - ⇑ {(val_sent-save_sent)//1024}")

