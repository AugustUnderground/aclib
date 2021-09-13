(import os)
(import shutil)
(import importlib)
(import [pkg-resources [get-distribution]])
(import [typing [Union]])

(require [hy.contrib.walk [let]])
(require [hy.contrib.loop [loop]])
(require [hy.extra.anaphoric [*]])

(setv __name__ "aclib"
      __version__ (-> __name__ (get-distribution) (. version)))

(defn get-maven-home [] 
  """
  Get the default maven home directory.
  """
  (let [mvn-command (+ "mvn help:evaluate " 
                     "-Dexpression=settings.localRepository "
                     "-B 2> /dev/null")]
    (if (shutil.which "mvn")
      (first (list (filter (fn [l] (-> l (.startswith "[") (not))) 
               (-> mvn-command (os.popen) (.read) (.split :sep "\n")))))
      (raise (ChildProcessError errno.ECHILD 
                                (os.strerror errno.ECHILD) 
                                "sh: command not found: mvn")))))

(defn default-class-path []
  """
  Get the expected class path for the `nutmeg-reader` jar, including all
  dependencies.
  """
  (let [maven-home (get-maven-home)
        class-path (.format (+ "{}/edlab/eda/characterization/{}/"
                               "characterization-{}-jar-with-dependencies.jar")
                            maven-home __version__ __version__)]
    (if (and (os.path.isfile class-path)
          (os.access class-path os.R-OK))
      class-path
      (raise (FileNotFoundError errno.ENOENT 
                                (os.strerror errno.ENOENT) 
                                class-path)))))

(defn jmap-to-dict [jmap]
  """
  Convert Java HashMap to native Python dictionary.
  """
  (dfor (, k v) (.items (dict jmap))
    [(str k) v.real]))

(defn jna-to-list [jna]
  """
  Convert Java Numeric List/Array to native Python list.
  """
  (list (map #%(.real %1) jsa)))

(defn jsa-to-list [jsa]
  """
  Convert Java String List/Array to native Python list.
  """
  (list (map str jsa)))
