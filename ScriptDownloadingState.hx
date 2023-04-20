import sys.Http;
import haxe.Json;
import flixel.addons.display.FlxBackdrop;
import funkin.menus.ui.Alphabet;
import sys.FileSystem;
import sys.io.File;


var bg:FlxBackdrop;
var scripts = [];
var modName:Alphabet;
var authorName:Alphabet;
var curItemSelected = 0;
var curFolderSelected = 0;

var data = null;

var modSelected = false;

var scriptCode:Array<String>;
var curMod = '';

var helpTxt:FlxText;

function create()
{
    var rawgitData = getGitFile('BCT2006','cne-scripts-testing','scripts.json'); //dont change this link!
    var rawData = Http.requestUrl(rawgitData.download_url);
    trace(rawData);
    data = Json.parse(rawData);

    bg = new FlxBackdrop();
	bg.loadGraphic(Paths.image('editors/bgs/charter'));
	bg.antialiasing = true;
	add(bg);

    helpTxt = new FlxText(0,200,4000,"Select a script!",24);
    helpTxt.autoSize = false;
    helpTxt.alignment = 'center';
    helpTxt.font = Paths.font('vcr.ttf');
    helpTxt.screenCenter(FlxAxes.X);
    add(helpTxt);

    var title = new FlxText(0,70,999,'Codename Script downloader',64);
    title.autoSize = false;
    title.alignment = 'center';
    title.font = Paths.font('funkin.otf');
    title.screenCenter(FlxAxes.X);
    add(title);
 

    for(i in data.mods)
    {
        scripts.push(i.name);
        trace(i.name);
    }
    modName = new FlxText(0,300,999,scripts[curItemSelected],45);
    modName.autoSize = false;
    modName.alignment = 'center';
    modName.font = Paths.font('funkin.otf');
    modName.screenCenter(FlxAxes.X);
    add(modName);

    authorName = new FlxText(0,400,999,data.mods[curItemSelected].author,35);
    authorName.autoSize = false;
    authorName.alignment = 'center';
    authorName.font = Paths.font('funkin.otf');
    trace(data.mods[curItemSelected].author);
    authorName.screenCenter(FlxAxes.X);
    add(authorName);

    trace(scripts);
    
}
function changeItem(huh:Int = 0)
{
	
	curItemSelected += huh;
    if (curItemSelected >= scripts.length)
        curItemSelected = 0;
    if (curItemSelected < 0)
        curItemSelected = scripts.length - 1;
    trace(curItemSelected);
    changeText(modName, scripts[curItemSelected]);
    changeText(authorName, data.mods[curItemSelected].author);

}
function changeModItem(huh:Int = 0)
{
    var mods = [];
    for (file in FileSystem.readDirectory('mods')) {
        if(FileSystem.isDirectory('mods/'+file))
        {
            mods.push(file);
        }
    }
    
    curFolderSelected += huh;
    if (curFolderSelected >= mods.length)
        curFolderSelected = 0;
    if (curFolderSelected < 0)
        curFolderSelected = mods.length - 1;

    trace(curFolderSelected);
    curMod = mods[curFolderSelected];
    changeText(modName, mods[curFolderSelected]);
    changeText(authorName, '');
    
}
function modSelect()
{
    trace(scriptCode);
    for(i in scriptCode)
    {
        var code = '';
        trace('mods/'+curMod+'/'+i.intendedLocation+i.fileName);
        trace(i.source);
        if(!i.isLocal)
            code = Http.requestUrl(i.source);
        else
        {
            code = getGitFile('BCT2006','cne-scripts-testing','scripts/worldsEasiestHitsound.hx');
            code = Http.requestUrl(code.download_url);
        }
            
        trace(code);
        if(!FileSystem.exists('mods/'+curMod+'/'+i.intendedLocation))
        {
            FileSystem.createDirectory('mods/'+curMod+'/'+i.intendedLocation);
        }
        File.saveContent('mods/'+curMod+'/'+i.intendedLocation+i.fileName, code);
    }
    

    scriptCode = [];
    helpTxt.text = 'Select a script!';
    modSelected = false;
    changeText(modName, '');
    changeText(authorName, '');
    
}

function itemSelect()
{
    trace(data.mods[curItemSelected].contents);
   // var rawData = Http.requestUrl(data.mods[curItemSelected].contents.source);
    if(data.mods[curItemSelected].isZip)
    {} //wip
    else
    {
       // trace(rawData);
        scriptCode = data.mods[curItemSelected].contents;
        trace(scriptCode);
        //scriptCode = rawData;
    }
    changeText(modName, '');
    helpTxt.text = 'Select the mod you want to put it into.';
    changeText(authorName, '');
    modSelected = true;
}

function changeText(obg:FlxText,txt)
{
    obg.text = txt;
    // i made this function to try and made centered aligned alphabet, but man am i lazy c:
}
xSpeed = 40;
ySpeed = 20;
function update(elapsed) {
    xSpeed = FlxMath.lerp(xSpeed, 40, 0.06);
    ySpeed = FlxMath.lerp(ySpeed, 40, 0.06);

	bg.x +=  elapsed * xSpeed;
	bg.y += elapsed * ySpeed;

    if(!modSelected)
    {
        if (controls.LEFT_P)
        {
            xSpeed += -150;
            changeItem(-1);
        }
            

        if (controls.RIGHT_P)
        {
            xSpeed += 150;
            changeItem(1);
        }

        if (controls.ACCEPT)
        {
            itemSelect();
        }
    } else {
        if (controls.LEFT_P)
        {
            xSpeed += -150;
            changeModItem(-1);
        }
            

        if (controls.RIGHT_P)
        {
            xSpeed += 150;
            changeModItem(1);
        }

        if (controls.ACCEPT)
        {
            modSelect();
        }
    }

	if (FlxG.keys.justPressed.ESCAPE) {
		FlxG.switchState(new MainMenuState());
	}
}

function getGitFile(user,repository,path) {
	
	var url = 'https://api.github.com/repos/'+user+'/'+repository+'/contents/'+path;
	var data = Json.parse(__requestOnGitHubServers(url));
	
	
	return data;
	
}
function __requestOnGitHubServers(url:String) {
	var h = new Http(url);
	h.setHeader("User-Agent", "request");
	var r = null;
	h.onData = function(d) {
		r = d;
	}
	h.onError = function(e) {
		throw e;
	}
	h.request(false);
	return r;
}
function __parseGitHubException(obj:Dynamic):GitHubException {
	var msg:String = "(No message)";
	var url:String = "(No API url)";
	if (Reflect.hasField(obj, "message"))
		msg = Reflect.field(obj, "message");
	if (Reflect.hasField(obj, "documentation_url"))
		url = Reflect.field(obj, "documentation_url");
	return new GitHubException(msg, url);
}
