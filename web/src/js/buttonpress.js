<script type="text/javascript">
const shell = require('shelljs')


function launchdm() {
  var a = './launchdm.sh'
  shell.exec(a)
}
function launchcomp() {
  var a = './launchcomp.sh'
  shell.exec(a)

}
function launchcasual() {
  var a = './launchcasual.sh'
  var file = log()
  shell.exec(a)
}

//build into this - log function that saves status of launched instances
//function log() {
//}
</script>
