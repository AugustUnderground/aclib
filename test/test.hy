(import os)
(import [numpy :as np])
(import [pandas :as pd])
(import [datetime [datetime :as dt]])
(import [aclib :as ac])
(require [hy.contrib.walk [let]])
(require [hy.contrib.loop [loop]])
(require [hy.extra.anaphoric [*]])

(setv HOME       (os.path.expanduser "~")
      time-stamp (-> dt (.now) (.strftime "%H%M%S-%y%m%d"))
      nmos-path f"../models/xh035-nmos"
      pmos-path f"../models/xh035-pmos"
      sim-path f"{HOME}/Workspace/sim"
      pdk-path  f"{HOME}/gonzo/Opt/pdk/x-fab/XKIT/xh035/cadence/v6_6/spectre/v6_6_2/mos"
      jar-path  f"{HOME}/.m2/repository/edlab/eda/characterization/0.0.1/characterization-0.0.1-jar-with-dependencies.jar"
      ckt-path  f"../library")

(setv op (ac.sym-amp-xh035 pdk-path ckt-path))

(setv res (ac.evaluate-ciruit op))

(setv rp (ac.random-sizing op))
(setv ip (ac.initial-sizing op))

(reduce (fn [df p]
    (->> p (ac.simulate op) (df.append :ignore-index True)))
   (take 10 (repeatedly #%(ac.random-parameters op)))
   (pd.DataFrame :columns (ac.performance-parameters op)))
