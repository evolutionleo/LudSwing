// Coroutines are a way to execute code over the course of many frames/steps without holding
// up execution of other code in your game. This is often useful for cutscenes, AI, or UI
// animations.
// 
// GameMaker has no native support for coroutines. This one-script library adds support,
// albeit somewhat restricted by what's possible by bending and twisting GML. This library
// is, in principle, supported across all platforms though upsteam bugs may be present,
// especially on HTML5 and Opera GX targets.
// 
// This library was written by Juju Adams in 2021, and is MIT licensed. For a copy of the
// license, please scroll down to the System region.

#region Introduction
// 
// This implementation of coroutines has a particular syntax that needs to be followed.
// This syntax is built from macros, allowing for reasonably natural expressions to be
// written whilst the actual GML clutter is hidden from view.
// 
// Coroutines act as sort of "sandboxes" where code can be run semi-separately from the rest
// of your game. Coroutine code is run in the scope of a "coroutine root" created for each
// coroutine. Coroutine roots are structs and can store variables as you normally would.
// Coroutines can freely interact with code outside of the coroutine, though care should be
// taken to avoid writing code that is unstable if it is executed in a different order than
// intended (this is easy to do with asynchronous execution such as a coroutine).
// 
#endregion

#region Examples
// 
//    example = COROUTINE
//        oPlayer.x += 4;
//        oEnemy.x += 2;
//    END
// 
// Above is a very simple example of a basic (and kind of useful) coroutine. The
// COROUTINE macro starts the creation of the coroutine. After that we have two lines of
// standard GML that moves oPlayer and oEnemy rightwards at different speeds. Finally,
// the END macro closes the coroutine definition.
// 
// Note that the COROUTINE macro returns a value that is stored in the "example" variable.
// COROUTINE returns the "coroutine root" struct mentioned above. You should keep a
// reference to the coroutine root so you can interact and execute the coroutine.
// 
// Creating a coroutine does not begin execution. To execute a coroutine, you must call
// either the .RunOnce() or .RunContinuous() method for the coroutine root. A list of
// coroutine root methods can be found below.
// 
// Let's try something a bit more useful:
// 
//    example = COROUTINE
//        WHILE (oPlayer.x < 500) THEN
//            oPlayer.x += 4;
//            oEnemy.x += 4;
//        POP
//    END
// 
// Here we've used a WHILE macro to create a while-loop inside our coroutine. You can use
// standard GML while-loops inside a coroutine, there's nothing stopping you, but as
// described in the introduction, doing so will not allow the coroutine system to break
// out of the while-loop until it has completely finished. This is the opposite of what
// we typically want from a coroutine.
// 
// The use of the POP macro here is essential. Every WHILE and REPEAT macro must be matched
// by a POP macro, much like you'd match an open bracket and a close bracket. The code
// defined between WHILE/REPEAT and POP is the looped code. Other flow control macros
// (AWAIT / DELAY / YIELD) do not need POP and instead require a THEN macro:
//
//    example = COROUTINE
//        AWAIT (mouse_x > room_width/2) THEN
//        YIELD "mouse on the right" THEN
//        DELAY 1000 THEN
//        AWAIT (mouse_x < room_width/2) THEN
//        YIELD "mouse on the left" THEN
//    END
// 
// Since coroutine roots are structs, and coroutine code is executed in the scope of their
// root, we can pass data into a coroutine directly after it has been made.
// 
//    example = COROUTINE
//        WHILE (player.x < 500) THEN
//            player.x += 4;
//            enemy.x += 4;
//        POP
//    END
//    example.player = id; //We're the player!
//    example.enemy = instance_nearest(oEnemy);
// 
// Despite the variables "player" and "enemy" not being defined within the coroutine, we're
// able to set those variables for the coroutine root by writing to the struct. This is
// very helpful for passing in starting conditions for a coroutine.
// 
#endregion

#region Coroutine Macros
// 
// The following are valid coroutine macros:
//   
// COROUTINE:
//    Starts a coroutine definition. It must always be matched by an END
//    COROUTINE returns a "coroutine root" struct which should be used to execute the coroutine
//    Only one coroutine can be defined at once
//    
// END:
//    Ends the definition of a coroutine. It must be called to finish defining the coroutine
//    
// THEN:
//    Acts as a way to separate different coroutine operations
//    
// YEILD:
//    Instructs the coroutine to immediately pause execution and return a value
//    
// REPEAT:
//    Analogous to GameMaker's own repeat() loop
//    REPEAT operations must look like this:
//    
//       REPEAT <expression> THEN
//           //Further operations
//       POP
// 
// WHILE:
//    Analogous to GameMaker's own while() loop
//    WHILE operations must look like this:
//    
//       WHILE <condition> THEN
//           //Further operations
//       POP
//    
// POP:
//    Necessary to terminate a REPEAT or WHILE loop
//    It must not be used in other contexts
//    
// AWAIT:
//    Waits for its condition to return <true> then continues with execution
//    AWAIT instructions do not need to be POP'd
//    AWAIT operations must look like this:
//    
//       AWAIT <condition> THEN
//       //Further operations
//    
// DELAY:
//    Waits for a given amount of real time to pass. DELAY durations are measured in milliseconds
//    DELAY instructions do not need to be POP'd
//    DELAY operations must look like this:
//    
//       DELAY <expression> THEN
//       //Further operations
// 
#endregion

#region Coroutine Root Methods
// 
// Coroutine roots are created with the following methods:
// 
// .RunOnce([approxDuration = COROUTINE_DEFAULT_APPROX_DURATION])
//   Runs the coroutine until either it reaches the end of its code, or this method call.
//   takes longer (approximately) than the given duration. The duration is in milliseconds.
//   If no approximate duration has been specified, it defaults to
//   COROUTINE_DEFAULT_APPROX_DURATION (see below). Once the coroutine reaches the end of
//   its code, it stops.
// 
// .IsDone()
//   Returns whether the coroutine has finished executing. This is only applicable when
//   using .RunOnce()
// 
// .RunContinuous([approxDuration])
//   As .RunOnce(), though once the coroutine reaches the end of its code, it stops.
// 
// .Restart([keepVariables = false])
//   Resets all state variables for the coroutine, including resetting its "done" state
//   If the optional "wipeVariables" parameter is set to <true>, custom variables
//   that have been set during the lifespan of the coroutine will persist. By default,
//   this parameter is set to <false> which will clear out all custom variable entirely,
//   including initial starting conditions.
// 
// .Duplicate()
//   Creates a copy of the coroutine, with its state fully reset. THis is handy for
//   running the same code in a different context, for example a template coroutine
//   can be created for a UI animation and then re-used for each UI element that needs it.
// 
#endregion



#region Configuration

// Default number of microseconds to allow a coroutine to run when calling
// the .Run() / .RunOnce() methods without specifying a value
// This is a *lower bound* and, unless the coroutine yields or terminates
// execution will take at least as long as this duration
#macro COROUTINE_DEFAULT_APPROX_DURATION  1000

// You're welcome to edit these macros to match your needs
#macro COROUTINE  CoroutineBegin();CoroutineFunction(function(){
#macro END        });CoroutinePop();
#macro THEN       });CoroutineFunction(function(){
#macro YIELD      });CoroutineYield(function(){return 
#macro REPEAT     });CoroutineRepeat(function(){return 
#macro WHILE      });CoroutineWhile(function(){return 
#macro POP        });CoroutinePop();CoroutineFunction(function(){
#macro AWAIT      });CoroutineAwait(function(){return 
#macro DELAY      });CoroutineDelay(function(){return 

#endregion



#region (System)

// MIT License
// 
// Copyright (c) 2018 @jujuadams
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#macro __COROUTINES_VERSION "1.0.0"
#macro __COROUTINES_DATE    "2021-10-25"

show_debug_message("Welcome to Coroutines by @jujuadams! This is version " + __COROUTINES_VERSION + ", " + __COROUTINES_DATE);

global.__coroutineStartTime = undefined;
global.__coroutineYield = false;
global.__coroutineYieldValue = undefined;

#macro __COROUTINE_ASSERT_STACK_EMPTY  if (array_length(global.__coroutineStack) > 0) show_error("Coroutines:\nCannot define more than one coroutine at a time\n ", true);
#macro __COROUTINE_ASSERT_STACK_NOT_EMPTY  if (array_length(global.__coroutineStack) <= 0) show_error("Coroutines:\nMust use coroutine function after CoroutineBegin() and before CoroutineEnd()\n ", true);
#macro __COROUTINE_PUSH_TO_STACK  array_push(global.__coroutineStack, _new);
#macro __COROUTINE_PUSH_TO_PARENT  array_push(global.__coroutineStack[array_length(global.__coroutineStack)-1].__functionArray, _new);

global.__coroutineStack = [];

#region Definition functions

function CoroutineBegin()
{
    __COROUTINE_ASSERT_STACK_EMPTY;
    
    var _new = new __CoroutineRootClass();
    __COROUTINE_PUSH_TO_STACK;
    
    return _new;
}

function CoroutineFunction(_function)
{
    __COROUTINE_ASSERT_STACK_NOT_EMPTY;
    
    //Push this function into the struct at the top of the stack
    array_push(global.__coroutineStack[array_length(global.__coroutineStack)-1].__functionArray, method(global.__coroutineStack[0], _function));
}

function CoroutineYield(_yieldFunction)
{
    __COROUTINE_ASSERT_STACK_NOT_EMPTY;
    
    var _new = new __CoroutineYieldClass();
    _new.__yieldFunction = method(global.__coroutineStack[0], _yieldFunction);
    
    __COROUTINE_PUSH_TO_PARENT;
}

function CoroutineDelay(_delayFunction)
{
    __COROUTINE_ASSERT_STACK_NOT_EMPTY;
    
    var _new = new __CoroutineDelayClass();
    _new.__delayFunction = method(global.__coroutineStack[0], _delayFunction);
    
    __COROUTINE_PUSH_TO_PARENT;
}

function CoroutineRepeat(_countFunction)
{
    __COROUTINE_ASSERT_STACK_NOT_EMPTY;
    
    var _new = new __CoroutineRepeatClass();
    _new.__repeatsFunction = method(global.__coroutineStack[0], _countFunction);
    
    __COROUTINE_PUSH_TO_PARENT;
    __COROUTINE_PUSH_TO_STACK;
}

function CoroutineWhile(_conditionFunction)
{
    __COROUTINE_ASSERT_STACK_NOT_EMPTY;
    
    var _new = new __CoroutineWhileClass();
    _new.__whileFunction = method(global.__coroutineStack[0], _conditionFunction);
    
    __COROUTINE_PUSH_TO_PARENT;
    __COROUTINE_PUSH_TO_STACK;
}

function CoroutineAwait(_function)
{
    __COROUTINE_ASSERT_STACK_NOT_EMPTY;
    
    var _new = new __CoroutineAwaitClass();
    _new.__function = method(global.__coroutineStack[0], _function);
    
    __COROUTINE_PUSH_TO_PARENT;
}

function CoroutinePop()
{
    __COROUTINE_ASSERT_STACK_NOT_EMPTY;
    
    array_pop(global.__coroutineStack);
}

#endregion

#region __CoroutineRootClass()

function __CoroutineRootClass() constructor
{
    __functionArray = [];
    
    __index = 0;
    __done = false;
    
    static Restart = function()
    {
        __index = 0;
        __done = false;
        
        var _i = 0;
        repeat(array_length(__functionArray))
        {
            var _function = __functionArray[_i];
            if (is_struct(_function) && !is_method(_function)) _function.Restart();
            ++_i;
        }
    }
    
    static Duplicate = function()
    {
        var _new = __CoroutineRootClass();
        
        var _newFunctionArray = _new.__functionArray;
        var _i = 0;
        repeat(array_length(__functionArray))
        {
            var _function = __functionArray[_i];
            if (is_method(_function))
            {
                _newFunctionArray[@ _i] = method(_new, _function);
            }
            else if (is_struct(_function))
            {
                _newFunctionArray[@ _i] = _function.Duplicate(_new);
            }
            
            ++_i;
        }
        
        return _new;
    }
    
    static IsDone = function()
    {
        return __done;
    }
    
    static RunContinuous = function(_approxDuration = COROUTINE_DEFAULT_APPROX_DURATION)
    {
        return __Run(_approxDuration, false);
    }
    
    static RunOnce = function(_approxDuration = COROUTINE_DEFAULT_APPROX_DURATION)
    {
        return __Run(_approxDuration, true);
    }
    
    static __Run = function(_approxDuration, _runOnce)
    {
        if (__done) return undefined;
        
        global.__coroutineStartTime = get_timer();
        global.__coroutineYield = false;
        global.__coroutineYieldValue = undefined;
        
        do
        {
            //Call the relevant function
            var _function = __functionArray[__index];
            
            if (is_method(_function))
            {
                _function();
                ++__index;
            }
            else if (is_struct(_function))
            {
                //But wait, what if it's not a function? What if it's a nested coroutine rule?
                //Well, we'd better execute that then
                _function.__Run(_approxDuration);
                
                //Only more on to the next function when this coroutine is done
                if (_function.__done) __index++;
            }
            
            //Move to the next function
            if (__index >= array_length(__functionArray))
            {
                if (_runOnce)
                {
                    __done = true;
                }
                else
                {
                    Restart();
                }
            }
        }
        until (global.__coroutineYield || __done || (get_timer() - global.__coroutineStartTime > _approxDuration));
        
        return global.__coroutineYieldValue;
    }
}

#endregion

#region __CoroutineRepeatClass()

function __CoroutineRepeatClass() constructor
{
    __functionArray = [];
    __repeatsFunction = undefined;
    
    __index = 0;
    __done = false;
    
    __repeats = 1;
    __repeatCount = 0;
    
    static Restart = function()
    {
        __index = 0;
        __done = false;
        
        __repeats = 1;
        __repeatCount = 0;
        
        var _i = 0;
        repeat(array_length(__functionArray))
        {
            var _function = __functionArray[_i];
            if (is_struct(_function) && !is_method(_function)) _function.Restart();
            ++_i;
        }
    }
    
    static Duplicate = function(_newRoot)
    {
        var _new = __CoroutineRepeatClass();
        _new.__repeatsFunction = method(_newRoot, __repeatsFunction);
        
        var _newFunctionArray = _new.__functionArray;
        var _i = 0;
        repeat(array_length(__functionArray))
        {
            var _function = __functionArray[_i];
            if (is_method(_function))
            {
                _newFunctionArray[@ _i] = method(_newRoot, _function);
            }
            else if (is_struct(_function))
            {
                _newFunctionArray[@ _i] = _function.Duplicate(_newRoot);
            }
            
            ++_i;
        }
        
        return _new;
    }
    
    static __Run = function(_approxDuration)
    {
        if (__done) return undefined;
        
        //If this is the first function+repeat then set up our repeat count from the function/constant
        if ((__index == 0) && (__repeatCount == 0))
        {
            __repeats = __repeatsFunction();
            
            //Early out
            if (__repeats <= 0)
            {
                __done = true;
                return undefined;
            }
        }
        
        do
        {
            //Call the relevant function
            var _function = __functionArray[__index];
            
            if (is_method(_function))
            {
                _function();
                ++__index;
            }
            else if (is_struct(_function))
            {
                //But wait, what if it's not a function? What if it's a nested coroutine rule?
                //Well, we'd better execute that then
                _function.__Run(_approxDuration);
                
                //Only more on to the next function when this coroutine is done
                if (_function.__done) __index++;
            }
            
            //Move to the next function
            if (__index >= array_length(__functionArray))
            {
                //Increase our repeats count. If we've reached the end then call us done!
                ++__repeatCount;
                if (__repeatCount >= __repeats)
                {
                    __done = true;
                }
                else
                {
                    var _oldRepeats = __repeats;
                    var _oldRepeatCount = __repeatCount;
                    
                    Restart();
                    
                    __repeats = _oldRepeats;
                    __repeatCount = _oldRepeatCount;
                }
            }
        }
        until (global.__coroutineYield || __done || (get_timer() - global.__coroutineStartTime > _approxDuration));
    }
}

#endregion

#region __CoroutineWhileClass()

function __CoroutineWhileClass() constructor
{
    __functionArray = [];
    __whileFunction = undefined;
    
    __index = 0;
    __done = false;
    
    static Restart = function()
    {
        __index = 0;
        __done = false;
        
        var _i = 0;
        repeat(array_length(__functionArray))
        {
            var _function = __functionArray[_i];
            if (is_struct(_function) && !is_method(_function)) _function.Restart();
            ++_i;
        }
    }
    
    static Duplicate = function(_newRoot)
    {
        var _new = __CoroutineWhileClass();
        _new.__whileFunction = method(_newRoot, __whileFunction);
        
        var _newFunctionArray = _new.__functionArray;
        var _i = 0;
        repeat(array_length(__functionArray))
        {
            var _function = __functionArray[_i];
            if (is_method(_function))
            {
                _newFunctionArray[@ _i] = method(_newRoot, _function);
            }
            else if (is_struct(_function))
            {
                _newFunctionArray[@ _i] = _function.Duplicate(_newRoot);
            }
            
            ++_i;
        }
        
        return _new;
    }
    
    static __Run = function(_approxDuration = COROUTINE_DEFAULT_APPROX_DURATION)
    {
        if (__done) return undefined;
        
        //Check the while loop condition if one exists
        if (is_method(__whileFunction) && !__whileFunction())
        {
            __done = true;
            return undefined;
        }
        
        do
        {
            //Call the relevant function
            var _function = __functionArray[__index];
            
            if (is_method(_function))
            {
                _function();
                ++__index;
            }
            else if (is_struct(_function))
            {
                //But wait, what if it's not a function? What if it's a nested coroutine rule?
                //Well, we'd better execute that then
                _function.__Run(_approxDuration);
                
                //Only more on to the next function when this coroutine is done
                if (_function.__done) __index++;
            }
            
            //Move to the next function
            if (__index >= array_length(__functionArray))
            {
                //Increase our repeats count. If we've reached the end then call us done!
                if (is_method(__whileFunction) && !__whileFunction())
                {
                    __done = true;
                }
                else
                {
                    Restart();
                }
            }
        }
        until (global.__coroutineYield || __done || (get_timer() - global.__coroutineStartTime > _approxDuration));
    }
}

#endregion

#region __CoroutineYieldClass()

function __CoroutineYieldClass() constructor
{
    __yieldFunction = undefined;
    
    __done = false;
    
    static Restart = function()
    {
        __done = false;
    }
    
    static Duplicate = function(_newRoot)
    {
        var _new = __CoroutineYieldClass();
        _new.__yieldFunction = method(_newRoot, __yieldFunction);
        
        return _new;
    }
    
    static __Run = function()
    {
        global.__coroutineYield = true;
        global.__coroutineYieldValue = __yieldFunction();
        __done = true;
    }
}

#endregion

#region __CoroutineDelayClass()

function __CoroutineDelayClass() constructor
{
    __delayFunction = undefined;
    
    __done = false;
    __startTime = undefined;
    
    static Restart = function()
    {
        __done = false;
        __startTime = undefined;
    }
    
    static Duplicate = function(_newRoot)
    {
        var _new = __CoroutineDelayClass();
        _new.__delayFunction = method(_newRoot, __delayFunction);
        
        return _new;
    }
    
    static __Run = function()
    {
        if (__startTime == undefined) __startTime = current_time;
        if (current_time - __startTime > __delayFunction()) __done = true;
    }
}

#endregion

#region __CoroutineAwaitClass()

function __CoroutineAwaitClass() constructor
{
    __function = undefined;
    
    __done = false;
    
    static Restart = function()
    {
        __done = false;
    }
    
    static Duplicate = function(_newRoot)
    {
        var _new = __CoroutineAwaitClass();
        _new.__function = method(_newRoot, __function);
        
        return _new;
    }
    
    static __Run = function()
    {
        if (__function()) __done = true;
    }
}

#endregion

#endregion