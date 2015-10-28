java-wrapper Cookbook
======================
This is a wrapper cookbook for java modified to fit the alfresco internal testing process.
It currently installs java from a local repository.

Requirements
------------
java cookbook 1.7.0 or higher


Usage
-----
#### java-wrapper::java8 or java-wrapper::java7

e.g.
Just include `java-wrapper` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[java-wrapper::java8]"
  ]
}
```

License and Authors
-------------------
Authors: Sergiu Vidrascu (vsergiu@hotmail.com)
