/*9ED与SNW架构                       */
/* Akari.biliScript - v20130730 
 * Copyright (C) 2013 
 * <https://github.com/akaza-akari/Akari.biliScript>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * As additional permission under GNU GPL version 3 section 7, you
 * may distribute non-source (e.g., minimized or compacted) forms of
 * that code without the copy of the GNU GPL normally required by
 * section 4, provided you include this license notice and a URL
 * through which recipients can access the Corresponding Source.
 */
var playerState = Player.state;
if (playerState == 'playing')
    Player.pause();
if ( Global._get( "__isExecuted_akari" ) )
{
  stopExecution();
}

/* Namespace: Akari
 * Contains several namespace level functions.
 */
Akari = {};

/* Function: execute
 * Sets off the helper script running.
 *
 * mainComp
 *   The MainComposition of the Comment Art to present.
 */
Akari.execute = function( mainComp )
{
  // Create a global reference so that the main composition could be accessed in Expressions
  Global._set( "__mainComp_akari", mainComp );
  
  // Present the main composition
  mainComp.present();
  
  // Set global value to indicate usage
  Global._set( "__isExecuted_akari", true );

};

/* Function: stop
 * Stops the helper for debug use
 */
Akari.stop = function()
{
  if ( Akari.isExecuted() )
  {
    ( Global._get("__mainComp_akari") ).detach();
    Global._set( "__mainComp_akari", null );
    Global._set( "__isExecuted_akari", null );

  }
};

/* Function: isExecuted
 * See if the helper is already running
 */
Akari.isExecuted = function()
{
  return ( Global._get("__isExecuted_akari") === true );
};

/* Property: root
 * A safe replacement for $.root in case it get banned
 */
Akari.root = function()
{
  if( $.hasOwnProperty("root") && $.root )
  {
    return $.root;
  }
  else
  {
    var sprite = $.createCanvas(
    {
      lifeTime : 810114514
    });

    ScriptManager.popEl( sprite );
    
    // remove 3D to make it clear by default
    sprite.transform.matrix3D = null;
    
    return sprite;
  }
}();

/* Namespace: Akari.Utilities
 * Provide utilities not directly related to presenting content.
 */
Akari.Utilities = {};

/* Static Class: Factory
 * Provides functions for creating and manipulating objects.
 * Legacy name used because this was once an actual factory. (See: 2012/11/21 Update)
 */
Akari.Utilities.Factory =
{
  /* Function: collapse
   * Concats all arrays given into one.
   *
   * arrays
   *   An Array of Arrays.
   */
  collapse : function( arrays )
  {
    var result = [];
    
    for ( var i = 0; i < arrays.length; i ++ )
    {
      result = result.concat( arrays[ i ] );
    }
    
    return result;
  },
  
  /* Function: extend
   * Copies all properties from the source to the destination object.
   *
   * destination
   *   Destination object.
   * source
   *   Source object.
   */
  extend : function( destination, source )
  {
    // Iterate through the source
    foreach ( source, function( key, object )
    {
      destination[ key.toString() ] = object;
    });
    
    return destination;
  },
  
  /* Function: clone
   * Clones an Object.
   *
   * object
   *   The Object to clone.
   */
  clone : function( object, scope )
  {
    // It just might happen to be nothing.
    if ( ! object )
    {
      return object;
    }

    // Check if the object contains a custom clone function for cloning private variables.
    if ( object.hasOwnProperty( "clone" ) )
    {
      return object.clone();
    }
    else if ( typeof object === "function" )
    {
      return function() { return object.apply( scope, arguments ); };
    }
    else
    {
      // Iterate through the Object running this clone function
      var newObject = {};
      var countProperties = 0;

      foreach ( object, function( key, object )
      {
        countProperties ++;
        
        if ( typeof object === "function" )
        {
          newObject[ key ] = function() { return object.apply( newObject, arguments ); };
        }
        else
        {
          var adg = Akari.Utilities.Factory.clone( object );
          newObject[ key ] = adg;
        }
      });
      
      // Check if newObject is empty
      if ( countProperties === 0 )
      {
        // Probably AS3 or an empty shit, make a clone first
        newObject = clone( object );

        if ( object.hasOwnProperty( "numChildren" ) || object.hasOwnProperty( "graphics" ) )
        {
          newObject = $.createCanvas(
          {
            lifeTime : 810114514
          });

          ScriptManager.popEl( newObject );

          // copy some displayObject parameters
          newObject.alpha = object.alpha;
          newObject.blendMode = object.blendMode;
          newObject.filters = object.filters;
          newObject.rotationX = object.rotationX;
          newObject.rotationY = object.rotationY;
          newObject.rotationZ = object.rotationZ;
          newObject.scaleX = object.scaleX;
          newObject.scaleY = object.scaleY;
          newObject.scaleZ = object.scaleZ;
          newObject.scrollRect = object.scrollRect;
          newObject.transform.colorTransform = object.transform.colorTransform;
          newObject.transform.matrix = object.transform.matrix;
          newObject.transform.matrix3D = object.transform.matrix3D;
        }
        
        // Check if it's a DOC
        if ( object.hasOwnProperty( "numChildren" ) )
        {
          for ( var i = 0; i < object.numChildren; i ++ )
          {
            newObject.addChild( Akari.Utilities.Factory.clone( object.getChildAt( i ) ) );
          }
        }
        
        // Check if it's a Shape
        if ( object.hasOwnProperty( "graphics" ) )
        {
          // Clone the Graphic's content
          newObject.graphics.copyFrom( object.graphics );
        }
      }
      
      return newObject;
    }
  },
  
  /* Function: replicate
   * Returns an Array of Objects created according to given params. 
   *
   * constructor
   *   Constructor of the Class to replicate.
   * count
   *   Count of result Objects.
   * paramsFunction
   *   A Function accepting index as parameter, returning an Array of parameters.
   */
  replicate : function( constructor, count, paramsFunction )
  {
    var objects = [];
    
    var i = 0;
    for ( i = 0; i < count; i ++ )
    {
      var newParams;
      
      newParams = paramsFunction ? paramsFunction( i ) : [];
      
      objects.push( constructor.apply( this, newParams ) );
    }
    
    return objects;
  }
};

/* Static Class: Timer
 * Improves timing precision over Player.time by sampling time usage for each frame. For retaining both smoothness and seekability.
 */
Akari.Utilities.Timer = function()
{
  var lastTime = 0;
  var deltaTime = 0;
  var sampleCount = 1;
  
  return
  {
    time : 0,
    
    /* Function: update
     * Counts a frame and updates time.
     */
    update : function()
    {
      if ( Player.time != lastTime )
      {
        // Make drastic change proof
        if ( Math.abs( Player.time - lastTime ) < 1000 )
        {
          deltaTime = ( Player.time - lastTime ) / sampleCount;
          lastTime = Player.time;
          sampleCount = 1;
          
          this.time = Player.time;
        }
        else
        {
          // Reset Timer because of a possible seek (or just so laggy that Timer is not effective)
          deltaTime = 0;
          lastTime = Player.time;
          sampleCount = 1;
          
          this.time = Player.time;
        }
      }
      else
      {
        this.time = lastTime + deltaTime * sampleCount;
        sampleCount ++;
      }
    }
  };
}();

/* Class: Binder
 * Provides functions for binding properties. Mainly used in layers.
 *
 * object
 *   An Object to bind.
 * properties
 *   An Object, containing values or Bindings for each property.
 * overridePathCheck
 *   [default] false
 *   Specifying this will override path checking, so that new properties can be added to the object.
 *   It is impossible to add new properties on AS3 objects (Error #1056), hence the protective mechanism. Override only if the feature is needed.
 */
Akari.Utilities.Binder = function()
{
  var binderClass = function( params )
  {
    var registry = [];
    var lookup = {};
    var needRefresh = true;

    var setParam = function( object, name, value )
    {
      var dotIndex = name.indexOf(".");
      if ( dotIndex < 0 )
      {
        if ( params.overridePathCheck || object.hasOwnProperty( name ) )
        {
          object[ name ] = value;
        }
      }
      else
      {
        var midName = name.substring( 0, dotIndex );
        if ( params.overridePathCheck )
        {
          if ( !object.hasOwnProperty( midName ) )
          {
            object[ midName ] = {};
          }
          setParam( object[ midName ], name.substring( dotIndex + 1 ), value );
        }
        else
        {
          if ( object.hasOwnProperty( midName ) )
          {
            setParam( object[ midName ], name.substring( dotIndex + 1 ), value );
          }
        }
      }
    };
    
    foreach( params.properties, function( key, obj )
    {
      var changeType = null;
      var value = null;

      if ( typeof( obj ) === "function" )
      {
        changeType = 100;
      }
      else if ( obj.hasOwnProperty( "linkFunc" ) )
      {
        changeType = obj.linkFunc ? 201 : 200;
      }
      else if ( obj.hasOwnProperty( "multiFunc" ) )
      {
        changeType = 300;
      }
      else
      {
        value = obj;
      }

      registry.push( [ key, obj, changeType, [], value ] );
    });

    // second pass generates dependency
    for ( var k = registry.length; k --; )
    {
      lookup[ registry[ k ][ 0 ] ] = k;
    }

    for ( var k = registry.length; k --; )
    {
      if ( registry[ k ][ 2 ] === 201 || registry[ k ][ 2 ] === 200 )
      {
        var dependency = [];
        var names = [ registry[ k ][ 1 ].names ];

        while ( names.length > 0 )
        {
          var currentNames = names.pop();
          dependency = dependency.concat( currentNames );
          for ( var n = currentNames.length; n --; )
          {
            if ( registry[ 0 + lookup[ "" + currentNames[ n ] ] ][ 2 ] === 201 || registry[ 0 + lookup[ "" + currentNames[ n ] ] ][ 2 ] === 200 )
            {
              names.push( registry[ 0 + lookup[ "" + currentNames[ n ] ] ][ 1 ].names );
            }
          }
        }

        registry[ k ][ 3 ] = dependency;
      }
    }

    // sort by dependency
    registry.sort( function( a, b )
    {
      if ( a[ 3 ].length !== 0 && b[ 3 ].length === 0 )
      {
        return 1;
      }
      if ( a[ 3 ].length === 0 && b[ 3 ].length !== 0 )
      {
        return -1;
      }
      if ( a[ 3 ].indexOf( b[ 0 ] ) >= 0 )
      {
        return 1;
      }
      if ( b[ 3 ].indexOf( a[ 0 ] ) >= 0 )
      {
        return -1;
      }
      if ( a[ 2 ] && !b[ 2 ] )
      {
        return 1;
      }
      else if ( b[ 2 ] && !a[ 2 ] )
      {
        return -1;
      }
      return 0;
    });

    var loopStart = registry.length;
    for ( var k = registry.length; k --; )
    {
      lookup[ registry[ k ][ 0 ] ] = k;
      if ( registry[ k ][ 2 ] )
      {
        loopStart = k;
      }
      else
      {
        setParam( params.object, registry[ k ][ 0 ], registry[ k ][ 4 ] );
      }
    }
    
    return
    {
      
      /* Function: update
       * Updates the object to fit the timeline.
       *
       * time
       *   A Number, the current time (in milliseconds) on the Composition's timeline.
       * scope
       *   [default] object
       *   An Object, scope under which the binded functions are called.
       */
      update : function( time, scope )
      {

        for ( var i = loopStart; i < registry.length; i ++ )
        {
          switch ( registry[ i ][ 2 ] )
          {
            case 100 :

              registry[ i ][ 4 ] = registry[ i ][ 1 ].apply( scope || params.object, [ time ] );

              break;
            case 200 :
              // should be computed already
              registry[ i ][ 4 ] = registry[ 0 + lookup[ "" + registry[ i ][ 3 ][ 0 ] ] ][ 4 ];
              break;
            case 201 :
              var funcArgs = [];
              var names = registry[ i ][ 3 ];

              for ( var a = 0; a < names.length; a ++ )
              {
                funcArgs.push( registry[ 0 + lookup[ "" + names[ a ] ] ][ 4 ] );
              }

              funcArgs.push( time );

              registry[ i ][ 4 ] = registry[ i ][ 1 ].linkFunc.apply( scope || params.object, funcArgs );

              break;
            case 300 :

              registry[ i ][ 4 ] = registry[ i ][ 1 ].multiFunc.apply( scope || params.object, [ time ] );

              var names = registry[ i ][ 1 ].names;

              for ( var a = 0; a < names.length; a ++ )
              {
                setParam( params.object, names[ a ], registry[ i ][ 4 ][ a ] );
              }
              break;
          }
          setParam( params.object, registry[ i ][ 0 ], registry[ i ][ 4 ] );
        }

      }
    };
  };

  /* Class: Binder.Link
   * Represents a link between different properties.
   *
   * name
   *   The name of the property to link.
   * names
   *   [default] [ name ]
   *   Array of strings. Overrides name if specified.
   * linkFunc
   *   [default] null
   *   A Function accepting input & time from binder or null indicating copy.
   */
  binderClass.Link = function( params )
  {
    return
    {
      names : params.names || [ params.name ],
      linkFunc : params.linkFunc || null
    };
  };

  /* Class: Binder.Multi
   *
   * names
   *   Array of strings.
   * func
   *   A Function returning an array of values corresponding to names.
   */
  binderClass.Multi = function( params )
  {
    return
    {
      names : params.names,
      multiFunc : params.func
    };
  };
  
  return binderClass;
}();
/* Static Class: Color
 * Provides functions for color space conversions.
 */
Akari.Utilities.Color = function()
{
  var xN = 0.95047;
  var yN = 1.0000;
  var zN = 1.08883;

  var labInvF = function( t )
  {
    if ( t > 0.008856451679035631 )
    {
      return t * t * t;
    }
    else
    {
      return 0.12841854934601665 * ( t - 0.13793103448275862 );
    }
  };

  return {
    hslToRgb : function( hsl )
    {
      var h = hsl[ 1 ] % 360;
      var c = ( 1 - Math.abs( 2 * hsl[ 3 ] - 1 ) ) * hsl[ 2 ];
      var x = c * ( 1 - Math.abs( ( h / 60 ) % 2 - 1 ) );
      var m = hsl[ 3 ] - c / 2;

      if ( h < 60 )
      {
        return [ c + m, x + m, m ];
      }
      if ( h < 120 )
      {
        return [ x + m, c + m, m ];
      }
      if ( h < 180 )
      {
        return [ m, c + m, x + m ];
      }
      if ( h < 240 )
      {
        return [ m, x + m, c + m ];
      }
      if ( h < 300 )
      {
        return [ x + m, m, c + m ];
      }
      return [ hsl[ 0 ], c + m, m, x + m ];
    },

    labToRgb : function( lab )
    {
      var t = ( lab[ 1 ] + 16 ) / 116;

      var xyz =
      [
        xN * labInvF( t + lab[ 2 ] / 500 ),
        yN * labInvF( t ),
        zN * labInvF( t - lab[ 3 ] / 200 )
      ];

      var rgb =
      [
        lab[ 0 ],
        3.2406 * xyz[ 0 ] - 1.5372 * xyz[ 1 ] - 0.4986 * xyz[ 2 ],
        - 0.9689 * xyz[ 0 ] + 1.8758 * xyz[ 1 ] + 0.0415 * xyz[ 2 ],
        0.0557 * xyz[ 0 ] - 0.2040 * xyz[ 1 ] + 1.0570 * xyz[ 2 ]
      ];

      for ( var i = 2; i >= 1; i -- )
      {
        if ( rgb[ 0 + i ] > 0.0031308 )
        {
          rgb[ 0 + i ] = 1.055 * Math.pow( rgb[ 0 + i ], 1 / 2.4 ) - 0.055;
        }
        else
        {
          rgb[ 0 + i ] = 12.92 * rgb[ 0 + i ];
        }
      }

      return rgb;
    },

    rgbToHardware : function( rgb )
    {
      var r = Math.min( 255, Math.max( 0, Math.floor( rgb[ 1 ] * 255 ) ) );
      var g = Math.min( 255, Math.max( 0, Math.floor( rgb[ 2 ] * 255 ) ) );
      var b = Math.min( 255, Math.max( 0, Math.floor( rgb[ 3 ] * 255 ) ) );
      return ( r << 16 ) | ( g << 8 ) | b;
    },

    rgbToTransformTint : function( rgb )
    {
      return $.createColorTransform( rgb[ 1 ], rgb[ 2 ], rgb[ 3 ], rgb[ 0 ] );
    },

    rgbToTransformAdd : function( rgb )
    {
      return $.createColorTransform( 1, 1, 1 ,1, rgb[ 1 ] * 255, rgb[ 2 ] * 255, rgb[ 3 ] * 255, rgb[ 0 ] * 255 );
    }
  };
}();

Akari.Utilities.Color.hsvToHardware = function( h, s, v )
{
  s = s > 1 ? 1 : (s < 0 ? 0 : s);
  v = v > 1 ? 1 : (v < 0 ? 0 : v);
  if (s == 0) return v * 0xFF << 16 | v * 0xFF << 8 | v * 0xFF << 0;
   h = h >= 360 ? h % 360 : (h < 0 ? h % 360 + 360 : h);
  var i = Math.floor(h / 60);
  var f = h / 60 - i;
  var p = v * (1 - s);
  var q = v * (1 - s * f);
  var t = v * (1 - s * (1 - f));
  switch (i) {
        case 0: return v * 0xFF << 16 | t * 0xFF << 8 | p * 0xFF << 0;
        case 1: return q * 0xFF << 16 | v * 0xFF << 8 | p * 0xFF << 0;
        case 2: return p * 0xFF << 16 | v * 0xFF << 8 | t * 0xFF << 0;
        case 3: return p * 0xFF << 16 | q * 0xFF << 8 | v * 0xFF << 0;
        case 4: return t * 0xFF << 16 | p * 0xFF << 8 | v * 0xFF << 0;
        case 5: return v * 0xFF << 16 | p * 0xFF << 8 | q * 0xFF << 0;
      }
      return 0;
};
/* Static Class: Vector
 * Provides functions for vector operations.
 */
Akari.Utilities.Vector =
{
  add : function()
  {
    var dimension = arguments[ 0 ].length;
    var result = [];
    for ( var d = 0; d < dimension; d ++ )
    {
      result[ d ] = arguments[ 0 ][ d ];
    }

    for ( var i = 1; i < arguments.length; i ++ )
    {
      for ( var d = 0; d < dimension; d ++ )
      {
        result[ d ] += arguments[ i ][ d ];
      }
    }

    return result;
  },

  subtract : function( a, b )
  {
    var dimension = a.length;
    var result = [];

    for ( var d = 0; d < dimension; d ++ )
    {
      result[ d ] = a[ d ] - b[ d ];
    }

    return result;
  },

  dot : function( a, b )
  {
    var dimension = a.length;
    var result = 0;

    for ( var d = 0; d < dimension; d ++ )
    {
      result += a[ d ] * b[ d ];
    }

    return result;
  },

  scale : function( v, s )
  {
    var dimension = v.length;
    var result = [];

    for ( var d = 0; d < dimension; d ++ )
    {
      result[ d ] = v[ d ] * s;
    }

    return result;
  },

  length : function( v )
  {
    var dimension = v.length;
    var result = 0;

    for ( var d = 0; d < dimension; d ++ )
    {
      result += v[ d ] * v[ d ];
    }

    result = Math.sqrt( result );

    return result;
  },

  unit : function( v )
  {
    return this.scale( v, 1 / this.length( v ) );
  },

  angle : function( a, b )
  {
    return Math.acos( this.dot( a, b ) / ( this.length( a ) * this.length( b ) ) );
  }
};
/* Static Class: Randomizer
 * Provides functions creating randomizers by user provided seed.
 */
Akari.Utilities.Randomizer = function()
{
  // Common mixin for all types
  var randomizerMixin =
  {
    integer : function( min, max )
    {
      var t = this.uniform();
      return Math.floor( min + t * ( max - min ) );
    },
    gaussian : function()
    {
      var store = null;

      return function()
      {
        if ( store === null )
        {
          var x1 = this.uniform();
          var x2 = this.uniform();

          var t1 = Math.sqrt( -2 * Math.log( x1 ) );
          var t2 = 2 * Math.PI * x2;

          store = t1 * Math.sin( t2 );
          return t1 * Math.cos( t2 );
        }
        else
        {
          var ret = store;
          store = null;
          return ret;
        }
      };
    }(),

    vector : function( dimension )
    {
      var vector = [];
      var t;
      var len = 0;

      for ( var i = dimension; i --; )
      {
        t = this.gaussian();
        vector[ i ] = t;
        len += t * t;
      }

      len = Math.sqrt( len );

      for ( var i = dimension; i --; )
      {
        vector[ i ] = vector[ i ] / len;
      }

      return vector;
    }
  };

  var randomizerNs = 
  {
    createNative : function()
    {
      return Akari.Utilities.Factory.extend(
      {
        uniform : Math.random
      }, randomizerMixin );
    },

    createLCG : function( seed )
    {
      var seed = seed;

      return Akari.Utilities.Factory.extend(
      {
        uniform : function()
        {
          seed = ( 0x343FD * seed + 0x269EC3 ) % 0x100000000;
          return ( ( seed & 0x7FFF0000 ) >> 16 ) / 0x8000;
        }
      }, randomizerMixin );
    },

    createTwister : function( seed )
    {
      var numbers = [];
      var index = 0;

      numbers[ 0 ] = seed;
      for ( var i = 1; i < 624; i ++ )
      {
        numbers[ i ] = ( 0x6C078965 * ( numbers[ i - 1 ] ^ ( numbers[ i - 1 ] >>> 30 ) ) + i ) & 0xFFFFFFFF;
      }

      return Akari.Utilities.Factory.extend(
      {
        uniform : function()
        {
          if ( index > 623 )
          {
            for ( var k = 0; k < 624; k ++ )
            {
              var y = ( numbers[ k ] & 0x80000000 ) + ( numbers[ ( k + 1 ) % 624 ] & 0x7FFFFFFF );
              numbers[ k ] = numbers[ ( k + 397 ) % 624 ] ^ ( y >>> 1 );
              if ( y % 2 !== 0 )
              {
                numbers[ k ] = numbers[ k ] ^ 0x9908B0DF;
              }
            }

            index = 0;
          }

          var n = numbers[ index ];
          n = n ^ ( n >>> 11 );
          n = n ^ ( ( n << 7 ) & 0x9D2C5680 );
          n = n ^ ( ( n << 15 ) & 0xEFC60000 );
          n = n ^ ( n >>> 18 );
          index ++;

          // force the value into unsigned
          return ( n >>> 0 ) / 0x100000000;
        }
      }, randomizerMixin );
    }
  };

  var defaultRandomizer = randomizerNs.createTwister( 810114514 );

  return Akari.Utilities.Factory.extend( Akari.Utilities.Factory.extend( defaultRandomizer, randomizerMixin ), randomizerNs );
}();
/* Namespace: Akari.Animation
 * This sort of classes are helpers for creating animation.
 */

Akari.Animation = {};
/* Class: BezierComponent
 * Represents one component of a bezier curve.
 *
 * cp
 *  Array of numbers. Coordinates of control points of the component.
 */
Akari.Animation.BezierComponent = function()
{
  var calcBezier = function( t )
  {
    var a = [];
    a[ 0 ] = this.cp;

    for ( var jr = 1; jr < this.cp.length; jr ++ )
    {
      a[ jr ] = [];
      for ( var ir = 0; ir < this.cp.length - jr; ir ++ )
      {
        a[ jr ][ ir ] = ( 1 - t ) * a[ jr - 1 ][ ir ] + t * a[ jr - 1 ][ ir + 1 ];
      }
    }

    return a[ this.cp.length - 1 ][ 0 ];
  };

  var calcSlope = function( t )
  {
    var n = this.cp.length - 1;
    var invT = 1 - t;

    // A = ( 1 - t ) ^ ( n - i - 1 )
    // B = t ^ ( i - 1 )
    // C = ( n choose i )
    // d/dt = P[ i ] * A * B * C * ( i - n * t )
    var a = Math.pow( invT, n - 1 );
    var b = 1 / t;
    var c = 1;

    var sum = this.cp[ 0 ] * a * b * c * ( - n * t );

    for ( var i = 1; i <= n; i ++ )
    {
      // Update ABC values
      a = a / invT;
      b = b * t;
      c = c * ( n - i + 1 ) / i;

      sum += this.cp[ i ] * a * b * c * ( i - n * t );
    }

    return sum;
  };

  return function( cp )
  {
    return
    {
      cp : cp,
      calcBezier : calcBezier,
      calcSlope : calcSlope
    };
  };
}();

/* Class: Spline < Curve
 * Represents one spline.
 *
 * curves
 *  Array of Curves. Dimension is determined by the dimension of the first curve.
 * precision
 *  [default] undefined
 *  Number. Overrides default precision determined by implentations of Curve.
 */
Akari.Animation.Spline = function()
{
  var evaluateAt = function( t )
  {
    return this.evaluateAtLength( this.length * t );
  };

  var evaluateAtLength = function( length, precision )
  {
    var i = 0;

    if ( length < 0 )
    {
      length = 0;
      i = 0;
    }
    else if ( length > this.length )
    {
      length = this.length;
      i = this.curves.length - 1;
    }
    else
    {
      // binary search for the corresponding segment
      var start = 0;
      var end = this.curves.length - 1;
      var loopFlag = true;

      do
      {
        i = Math.floor( ( start + end ) / 2 );

        if ( this.segmentsPosition[ i ] > length )
        {
          end = i;
        }
        else if ( this.segmentsPosition[ i + 1 ] < length )
        {
          if ( i === end - 1 )
          {
            i ++;
            loopFlag = false;
          }
          else
          {
            start = i;
          }
        }
        else
        {
          loopFlag = false;
        }

      } while ( loopFlag );
    }

    // call segment's evaluateAtLength
    if ( precision )
    {
      return this.curves[ i ].evaluateAtLength( length - this.segmentsPosition[ i ], precision );
    }
    else
    {
      return this.segmentsPolyline[ i ].evaluateAtLength( length - this.segmentsPosition[ i ] );
    }
  };

  var getLength = function()
  {
    return this.length;
  };

  var toPolyline = function( precision )
  {
    var newPoints = [];
    if ( precision )
    {
      for ( var i = 0; i < this.curves.length; i ++ )
      {
        newPoints = newPoints.concat( this.curves[ i ].toPolyline( precision ) );
      }

      return Akari.Animation.Polyline( newPoints );
    }
    else
    {
      // just concat stock points
      for ( var i = 0; i < this.segmentsPolyline.length; i ++ )
      {
        newPoints = newPoints.concat( this.segmentsPolyline[ i ].points );
      }

      return Akari.Animation.Polyline( newPoints );
    }
  };

  var concat = function( other )
  {
    var newCurves = this.points.concat( other.curves );
    return Akari.Animation.Spline( newCurves );
  };

  var cloneSelf = function()
  {
    return Akari.Animation.Spline( this.curves );
  };

  return function( curves, precision )
  {
    // calculate length of the spline
    var segmentsLength = [];
    var segmentsPosition = [];
    var segmentsPolyline = [];
    var length = 0;
    var segLength = 0;
    for ( var i = 0; i < curves.length; i ++ )
    {
      segmentsPolyline.push( curves[ i ].toPolyline( precision ) );
      segLength = segmentsPolyline[ i ].getLength();
      segmentsPosition.push( length );
      segmentsLength.push( segLength );
      length += segLength;
    }

    return
    {
      // Spline
      curves : curves,
      concat : concat,
      segmentsPolyline : segmentsPolyline,
      segmentsLength : segmentsLength,
      segmentsPosition : segmentsPosition,
      length : length,
      
      // Curve common
      dimension : curves[ 0 ].dimension,
      evaluateAt : evaluateAt,
      evaluateAtLength : evaluateAtLength,
      getLength : getLength,
      toPolyline : toPolyline,
      toSpline : cloneSelf
    };
  };
}();

/* Class: Polyline < Curve
 * Represents one polyline.
 *
 * points
 *  Array of Array<Number>s. Dimension is determined by the length of the first array.
 */
Akari.Animation.Polyline = function()
{
  var evaluateAt = function( t )
  {
    // Use evaluateAtLength for stuff, since this is easier for polyline
    return this.evaluateAtLength( this.length * t );
  };

  var evaluateAtLength = function( length )
  {

    var i = 0;

    if ( length < 0 )
    {
      length = 0;
      i = 0;
    }
    else if ( length > this.length )
    {
      length = this.length;
      i = this.points.length - 2;
    }
    else
    {
      // binary search for the corresponding segment
      var start = 0;
      var end = this.points.length - 2;
      var loopFlag = true;

      do
      {
        i = Math.floor( ( start + end ) / 2 );

        if ( this.segmentsPosition[ i ] > length )
        {
          end = i;
        }
        else if ( this.segmentsPosition[ i + 1 ] < length )
        {
          if ( i === end - 1 )
          {
            i ++;
            loopFlag = false;
          }
          else
          {
            start = i;
          }
        }
        else
        {
          loopFlag = false;
        }

      } while ( loopFlag );
    }
    
    // interpolate
    var p1 = this.points[ i ];
    var p2 = this.points[ i + 1 ];
    var t = ( length - this.segmentsPosition[ i ] ) / this.segmentsLength[ i ];
    var ret = [];

    for ( var d = this.dimension - 1; d >= 0; d -- )
    {
      ret.unshift( p2[ d ] * t + p1[ d ] * ( 1 - t ) );
    }

    return ret;
  };

  var concat = function( other )
  {
    var newPoints = this.points.concat( other.points );
    return Akari.Animation.Polyline( newPoints );
  };

  var getLength = function()
  {
    return this.length;
  };

  var cloneSelf = function()
  {
    return Akari.Animation.Polyline( this.points );
  };
 
  var toSpline = function()
  {
    return Akari.Animation.Spline( [ this ] );
  };

  return function( points )
  {
    // calculate length of the polyline
    var segmentsLength = [];
    var segmentsPosition = [];
    var length = 0;
    var segLength = 0;
    var distance = 0;
    for ( var i = 0; i < points.length - 1; i ++ )
    {
      segLength = 0;
      for ( var d = 0; d < points[ 0 ].length; d ++ )
      {
        distance = points[ i + 1 ][ d ] - points[ i ][ d ];
        segLength += distance * distance;
      }

      segLength = Math.sqrt( segLength );
      segmentsPosition.push( length );
      segmentsLength.push( segLength );
      length += segLength;
    }

    return
    {
      points : points,
      segmentsLength : segmentsLength,
      segmentsPosition : segmentsPosition,
      length : length,
      concat : concat,
      
      // Curve common
      dimension : points[ 0 ].length,
      evaluateAt : evaluateAt,
      evaluateAtLength : evaluateAtLength,
      getLength : getLength,
      toPolyline : cloneSelf,
      toSpline : toSpline
    };
  };
}();

/* Class: Bezier < Curve
 * Represents one bezier curve.
 *
 * points
 *  Array of Array<Number>s. Dimension is determined by the length of the first array.
 */
Akari.Animation.Bezier = function()
{
  var evaluateAt = function( t )
  {
    var ret = [];
    for ( var i = this.dimension - 1; i >= 0; i -- )
    {
      ret.unshift( this.components[ i ].calcBezier( t ) );
    }

    return ret;
  };

  var evaluateAtLength = function( length, precision )
  {
    // Convert to a polyline and evaluate
    return ( this.toPolyline( precision ) ).evaluateAtLength( length );
  };

  var getLength = function( precision )
  {
    // Convert to a polyline and measure polyline length
    return ( this.toPolyline( precision ) ).getLength();
  };

  var subdiv = function( precision, cp, removeRight )
  {
    // check if precision requirements are fulfilled
    var sumDelta = 0;
    var start = 0;
    var step = 0;

    for ( var d = cp.length - 1; d >= 0; d -- )
    {
      start = cp[ d ][ 0 ];
      step = ( cp[ d ][ cp[ d ].length - 1 ] - start ) / ( cp[ d ].length - 1 );
      for ( var i = cp[ d ].length - 2; i >= 1; i -- )
      {
        sumDelta += Math.abs( cp[ d ][ i ] - start - step * i );
      }
    }

    if ( sumDelta <= precision )
    {
      // return null indicating end of subdivision, treat as line
      return null;
    }
    else
    {
      // subdivide and create polyline
      var leftSegment = [];
      var rightSegment = [];
      var poly = [];

      for ( var d = cp.length - 1; d >= 0; d -- )
      {
        leftSegment[ d ] = [ cp[ d ][ 0 ] ];
        rightSegment[ d ] = [];
        poly[ d ] = cp[ d ];
      }

      do 
      {
        var poly2 = [];

        for ( var d = cp.length - 1; d >= 0; d -- )
        {
          poly2[ d ] = [];
          for ( var i = 0; i < poly[ d ].length - 1; i ++ )
          {
            poly2[ d ].push( ( poly[ d ][ i ] + poly[ d ][ i + 1 ] ) / 2 );
          }

          leftSegment[ d ].push( poly2[ d ][ 0 ] );
          rightSegment[ d ].push( poly2[ d ][ poly2[ d ].length - 1 ] );
        }

        poly = poly2;
      } while ( poly[ 0 ].length > 1 );

      for ( var d = cp.length - 1; d >= 0; d -- )
      {
        rightSegment[ d ].unshift( cp[ d ][ cp[ d ].length - 1 ] );
        rightSegment[ d ].reverse();
      }

      // compose resulting polyline from recursive calls
      var leftPoly = subdiv( precision, leftSegment, true );
      var rightPoly = subdiv( precision, rightSegment, removeRight );

      if ( ! leftPoly )
      {
        leftPoly = [ [] ];
        for ( var d = cp.length - 1; d >= 0; d -- )
        {
          leftPoly[ 0 ].unshift( cp[ d ][ 0 ] );
        }
      }

      if ( rightPoly )
      {
        var retPoly = leftPoly.concat( rightPoly );
        return retPoly;
      }
      else
      {
        var tmp = [];

        for ( var d = cp.length - 1; d >= 0; d -- )
        {
          tmp.unshift( rightSegment[ d ][ 0 ] );
        }
        leftPoly.push( tmp );

        if ( ! removeRight )
        {
          tmp = [];

          for ( var d = cp.length - 1; d >= 0; d -- )
          {
            tmp.unshift( rightSegment[ d ][ rightSegment[ d ].length - 1 ] );
          }
          leftPoly.push( tmp );
        }

        return leftPoly;
      }
    }
  };

  var toPolyline = function( precision )
  {
    if ( ! precision )
    {
      // Derive precision from coordinate range, assure 1/100 precision
      var max = 0;
      var min = Math.pow( 10, 309 );

      for ( var d = this.cp.length - 1; d >= 0; d -- )
      {
        for ( var i = this.cp[ d ].length - 1; i >= 0; i-- )
        {
          if ( this.cp[ d ][ i ] > max )
          {
            max = this.cp[ d ][ i ];
          }
          else if ( this.cp[ d ][ i ] < min )
          {
            min = this.cp[ d ][ i ];
          }
        }
      }

      precision = ( max - min ) / 100;
    }

    return Akari.Animation.Polyline( subdiv( precision, this.cp, false ) || [ this.points[ 0 ], this.points[ this.points.length - 1 ] ] );
  };
 
  var toSpline = function()
  {
    return Akari.Animation.Spline( [ this ] );
  };

  return function( points )
  {
    // extract cp array for subdivision, evaluation and stuff
    var cp = [];
    var compo = [];

    for ( var d = points[ 0 ].length - 1; d >= 0; d -- )
    {
      cp[ d ] = [];
      for ( var i = points.length - 1; i >= 0; i -- )
      {
        cp[ d ].unshift( points[ i ][ d ] );
      }

      compo[ d ] = Akari.Animation.BezierComponent( cp[ d ] );
    }

    return
    {
      // Bezier
      points : points,
      cp : cp,
      components : compo,
      
      // Curve common
      dimension : points[ 0 ].length,
      evaluateAt : evaluateAt,
      evaluateAtLength : evaluateAtLength,
      getLength : getLength,
      toPolyline : toPolyline,
      toSpline : toSpline
    };
  };
}();
 
/* Class: CurveTrace
 * Traces through a Curve.
 *
 * curve
 *   The Curve to use.
 * animation
 *   A Function( time ) that maps time to coefficient or length on the curve.
 * mode
 *   [default] "lengthProportion"
 *   "coefficient", "length" or "lengthProportion", how the value returned from the function is interpreted.
 */
Akari.Animation.CurveTrace = function( params )
{
  var mode = params.mode || "lengthProportion";

  if ( mode === "lengthProportion" )
  {
    return function( time )
    {
      return params.curve.evaluateAtLength( params.animation( time ) * params.curve.getLength() );
    };
  }
  else if ( mode === "length" )
  {
    return function( time )
    {
      return params.curve.evaluateAtLength( params.animation( time ) );
    };
  }
  else
  {
    return function( time )
    {
      return params.curve.evaluateAt( params.animation( time ) );
    };
  }
};

/* Static Class: Interpolation
 * Provides functions for interpolating between numbers.
 *
 * Common parameters for functions in this class:
 *
 * t
 *   A Number, time factor indicating position between the values.
 * value1
 *   A Number, the first value ( t = 0 ).
 * value2
 *   A Number, the second value ( t = 1 ).
 */
Akari.Animation.Interpolation =
{
  /* Function: dimension
   * Creates a multidimensional interpolation based on given function.
   *
   * interpolation
   *   The interpolation function to wrap.
   */
  dimension : function( interpolation )
  {
    return function( t, value1, value2 )
    {
      var result = [];
      
      for ( var i = 0; i < value1.length; i ++ )
      {
        result[ i ] = interpolation( t, value1[ i ], value2[ i ] );
      }
      
      return result;
    };
  },
  
  /* Function: hold
   * Holds value1
   */
  hold : function( t, value1, value2 )
  {
    return value1;
  },

  /* Function: linear
   * Interpolates in linear manner.
   */
  linear : function( t, value1, value2 )
  {
    return value1 + ( value2 - value1 ) * t;
  },

  /* Function: bezier
   * [expensive] Creates a bezier interpolation.
   * The resulting interpolation transforms the input t with the given control points, and treats the resulting t as a linear time factor.
   *
   * cpS, cpD
   *   Array of numbers. Coordinates on the source-t / destination-t axis.
   */
  bezier : function( cpS, cpD )
  {
    if ( cpS.length != cpD.length || cpS.length < 1 )
    {
      return Akari.Animation.Interpolation.linear;
    }

    // Only 0 < cpS < 1 are valid as a function of time
    for ( var i = cpS.length - 1; i >= 0; i -- ) {
      if ( cpS[ i ] < 0 || cpS[ i ] > 1 )
      {
        return Akari.Animation.Interpolation.linear;
      }
    }

    if ( cpS.length > 2 )
    {
      // higher order curves
      var calcBezier = function( t, cp )
      {
        var a = [];
        a[ 0 ] = cp;

        for ( var jr = 1; jr < cp.length; jr ++ )
        {
          a[ jr ] = [];
          for ( var ir = 0; ir < cp.length - jr; ir ++ )
          {
            a[ jr ][ ir ] = ( 1 - t ) * a[ jr - 1 ][ ir ] + t * a[ jr - 1 ][ ir + 1 ];
          }
        }

        return a[ cp.length - 1 ][ 0 ];
      };

      var calcSlope = function( t, cp )
      {
        var n = cp.length - 1;
        var invT = 1 - t;

        // A = ( 1 - t ) ^ ( n - i - 1 )
        // B = t ^ ( i - 1 )
        // C = ( n choose i )
        // d/dt = P[ i ] * A * B * C * ( i - n * t )
        var a = Math.pow( invT, n - 1 );
        var b = 1 / t;
        var c = 1;

        var sum = cp[ 0 ] * a * b * c * ( - n * t );

        for ( var i = 1; i <= n; i ++ )
        {
          // Update ABC values
          a = a / invT;
          b = b * t;
          c = c * ( n - i + 1 ) / i;

          sum += cp[ i ] * a * b * c * ( i - n * t );
        }

        return sum;
      };

      var newtonIterations = 2;
      var binaryIterations = 7;
      var sampleSize = 17;
    }
    else if ( cpS.length == 2 )
    {
      var calcBezier = function( t, cp )
      {
        var c1 = cp[ 1 ];
        var c2 = cp[ 2 ];
        return ( ( ( 1 - 3 * c2 + 3 * c1 ) * t + 3 * c2 - 6 * c1 ) * t + 3 * c1) * t;
      };

      var calcSlope = function( t, cp )
      {
        var c1 = cp[ 1 ];
        var c2 = cp[ 2 ];
        return 3 * c1 + t * ( 6 * c2 - 12 * c1 + t * ( 3 - 9 * ( c2 - c1 ) ) );
      };

      var newtonIterations = 2;
      var binaryIterations = 5;
      var sampleSize = 11;
    }
    else
    {
      var calcBezier = function( t, cp )
      {
        var c1 = cp[ 1 ];
        return ( ( t - 3 * c1 ) * t + 3 * c1) * t;
      };

      var calcSlope = function( t, cp )
      {
        var c1 = cp[ 1 ];
        return 3 * c1 + t * ( 3 * t - 6 * c1 );
      };

      var newtonIterations = 1;
      var binaryIterations = 3;
      var sampleSize = 3;
    }

    // Samples for initial guess
    var sampleS = [];
    var sampleStep = 1 / ( sampleSize - 1 );
    var allPointS = Akari.Utilities.Factory.collapse( [ 0, cpS, 1 ] );
    var allPointD = Akari.Utilities.Factory.collapse( [ 0, cpD, 1 ] );
    for ( var i = 0; i < sampleSize; i ++ )
    {
      sampleS[ i ] = calcBezier( i * sampleStep, allPointS );
    }

    var getInitialGuess = function( tS )
    {
      for ( var i = sampleS.length - 1; i >= 0; i -- )
      {
        // sampleS[ i ] just won't work. Don't know why, the player is so quirky
        var s = i;
        var s2 = i - 1;
        if ( i === 0 || sampleS[ s2 ] <= tS )
        {
          return [ i - 1, ( i - 1 + ( tS - sampleS[ s2 ] ) / ( sampleS[ s ] - sampleS[ s2 ] ) ) * sampleStep ];
        }
      }
      return [ 0, 0 ];
    };

    // Algorithm from Firefox's implementation of cubic-bezier
    var newton = function( tS, guessTI )
    {
      for ( var i = 0; i < newtonIterations; i ++ )
      {
        var currentX = calcBezier( guessTI, allPointS ) - tS;
        var currentSlope = calcSlope( guessTI, allPointS );

        if ( Math.abs( currentSlope ) <= 0.00001 )
        {
          return guessTI;
        }

        guessTI -= currentX / currentSlope;
      }

      return guessTI;
    };

    var binary = function( tS, start, end )
    {
      var currentX;
      var currentT;
      var i = 0;

      do
      {
        currentT = start + ( end - start ) / 2;
        currentX = calcBezier( currentT, allPointS ) - tS;

        if ( currentX > 0 )
        {
          end = currentT;
        }
        else
        {
          start = currentT;
        }
      } while ( Math.abs( currentX ) > 0.001 && ( ++ i ) < binaryIterations );

      return currentT;
    };

    if ( calcSlope )
    {
      var getTI = function( t )
      {
        var ig = getInitialGuess( t );
        var startPos = ig[ 0 ] * sampleStep;
        var guessTI = ig[ 1 ];

        var initialSlope = calcSlope( guessTI, allPointS );

        if ( initialSlope > 0.02 )
        {
          return newton( t, guessTI );
        }
        else if ( initialSlope == 0.0 )
        {
          return guessTI;
        }
        else 
        {
          return binary( t, startPos, startPos + sampleStep );
        }
      };
    }
    else
    {
      var getTI = function( t )
      {
        var ig = getInitialGuess( t );
        var startPos = ig[ 0 ] * sampleStep;

        return binary( t, startPos, startPos + sampleStep );
      };
    }

    return function( t, value1, value2 )
    {
      var tI = getTI( t );
      var tD = calcBezier( tI, allPointD );

      return value1 + ( value2 - value1 ) * tD;
    };
  },
  
  /* Function Group: cubic
   * Interpolates in cubic manner.
   */
  cubic :
  {
    easeIn : function( t, value1, value2 )
    {
      return value1 + ( value2 - value1 ) * t * t * t;
    },
    easeOut : function( t, value1, value2 )
    {
      return Akari.Animation.Interpolation.cubic.easeIn( 1 - t, value2, value1 );
    },
    easeInOut : function( t, value1, value2 )
    {
      var midPoint = ( value1 + value2 ) / 2;
      if ( t < 0.5 ) return Akari.Animation.Interpolation.cubic.easeIn( t * 2, value1, midPoint );
      return Akari.Animation.Interpolation.cubic.easeOut( t * 2 - 1, midPoint, value2 );
    },
    easeOutIn : function( t, value1, value2 )
    {
      var midPoint = ( value1 + value2 ) / 2;
      if ( t < 0.5 ) return Akari.Animation.Interpolation.cubic.easeOut( t * 2, value1, midPoint );
      return Akari.Animation.Interpolation.cubic.easeIn( t * 2 - 1, midPoint, value2 );
    }
  },
  
  /* Function Group: quartic
   * Interpolates in quartic manner.
   */
  quartic :
  {
    easeIn : function( t, value1, value2 )
    {
      return value1 + ( value2 - value1 ) * t * t * t * t;
    },
    easeOut : function( t, value1, value2 )
    {
      return Akari.Animation.Interpolation.quartic.easeIn( 1 - t, value2, value1 );
    },
    easeInOut : function( t, value1, value2 )
    {
      var midPoint = ( value1 + value2 ) / 2;
      if ( t < 0.5 ) return Akari.Animation.Interpolation.quartic.easeIn( t * 2, value1, midPoint );
      return Akari.Animation.Interpolation.quartic.easeOut( t * 2 - 1, midPoint, value2 );
    },
    easeOutIn : function( t, value1, value2 )
    {
      var midPoint = ( value1 + value2 ) / 2;
      if ( t < 0.5 ) return Akari.Animation.Interpolation.quartic.easeOut( t * 2, value1, midPoint );
      return Akari.Animation.Interpolation.quartic.easeIn( t * 2 - 1, midPoint, value2 );
    }
  },
  
  /* Function Group: quintic
   * Interpolates in quintic manner.
   */
  quintic :
  {
    easeIn : function( t, value1, value2 )
    {
      return value1 + ( value2 - value1 ) * t * t * t * t * t;
    },
    easeOut : function( t, value1, value2 )
    {
      return Akari.Animation.Interpolation.quintic.easeIn( 1 - t, value2, value1 );
    },
    easeInOut : function( t, value1, value2 )
    {
      var midPoint = ( value1 + value2 ) / 2;
      if ( t < 0.5 ) return Akari.Animation.Interpolation.quintic.easeIn( t * 2, value1, midPoint );
      return Akari.Animation.Interpolation.quintic.easeOut( t * 2 - 1, midPoint, value2 );
    },
    easeOutIn : function( t, value1, value2 )
    {
      var midPoint = ( value1 + value2 ) / 2;
      if ( t < 0.5 ) return Akari.Animation.Interpolation.quintic.easeOut( t * 2, value1, midPoint );
      return Akari.Animation.Interpolation.quintic.easeIn( t * 2 - 1, midPoint, value2 );
    }
  },
  
  /* Function Group: exponential
   * Interpolates in exponential manner.
   */
  exponential :
  {
    easeIn : function( t, value1, value2 )
    {
      return ( t === 0 ) ? value1 : value1 + ( value2 - value1 ) * Math.pow( 2, 10 * ( t - 1 ) );
    },
    easeOut : function( t, value1, value2 )
    {
      return Akari.Animation.Interpolation.exponential.easeIn( 1 - t, value2, value1 );
    },
    easeInOut : function( t, value1, value2 )
    {
      var midPoint = ( value1 + value2 ) / 2;
      if ( t < 0.5 ) return Akari.Animation.Interpolation.exponential.easeIn( t * 2, value1, midPoint );
      return Akari.Animation.Interpolation.exponential.easeOut( t * 2 - 1, midPoint, value2 );
    },
    easeOutIn : function( t, value1, value2 )
    {
      var midPoint = ( value1 + value2 ) / 2;
      if ( t < 0.5 ) return Akari.Animation.Interpolation.exponential.easeOut( t * 2, value1, midPoint );
      return Akari.Animation.Interpolation.exponential.easeIn( t * 2 - 1, midPoint, value2 );
    }
  },
  
  /* Function Group: back
   * Interpolates in a overflowing manner.
   *
   * s
   *   [default] 1.70158
   *   Back factor.
   */
  back :
  {
    s : 1.70158,
    easeIn : function( t, value1, value2 )
    {
      return ( value2 - value1 ) * t * t * (( Akari.Animation.Interpolation.back.s + 1 ) * t - Akari.Animation.Interpolation.back.s ) + value1;
    },
    easeOut : function( t, value1, value2 )
    {
      return Akari.Animation.Interpolation.back.easeIn( 1 - t, value2, value1 );
    },
    easeInOut : function( t, value1, value2 )
    {
      var midPoint = ( value1 + value2 ) / 2;
      if ( t < 0.5 ) return Akari.Animation.Interpolation.back.easeIn( t * 2, value1, midPoint );
      return Akari.Animation.Interpolation.back.easeOut( t * 2 - 1, midPoint, value2 );
    },
    easeOutIn : function( t, value1, value2 )
    {
      var midPoint = ( value1 + value2 ) / 2;
      if ( t < 0.5 ) return Akari.Animation.Interpolation.back.easeOut( t * 2, value1, midPoint );
      return Akari.Animation.Interpolation.back.easeIn( t * 2 - 1, midPoint, value2 );
    }
  }
};

/* Enum: KeyframeMode
 * Modes of keyframe behaviors.
 */
Akari.Animation.KeyframeMode =
{
  // affectNext: The keyframe's function will be used when time is between this keyframe and the next.
  affectNext : 0,
  
  // weightBlend: The keyframe's function and the next's will be used when time is between this keyframe and the next, according to weight settings and time factor.
  weightBlend : 1,
  
  // useNext: The next keyframe's function will be used when time is between this keyframe and the next.
  useNext : 2
};
 
/* Class: Keyframe
 * A class describing a keyframe.
 *
 * time
 *   Time (in milliseconds) the keyframe is at.
 * value
 *   Value of the keyframe.
 * interpolation
 *   [default] Interpolation.linear
 *   Function used to interpolate between this value and the next.
 * mode
 *   [default] KeyframeMode.affectNext
 *   Interpolation behavior of this keyframe.
 * weight
 *   [default] 1
 *   Weight when KeyframeMode.weightBlend is used.
 */
Akari.Animation.Keyframe = function( params )
{
  return
  {
    time : params.time,
    value : params.value,
    interpolation : params.interpolation || Akari.Animation.Interpolation.linear,
    mode : params.mode || Akari.Animation.KeyframeMode.affectNext,
    weight : params.weight || 1,
    
    /* Function: clone
     * Custom clone function.
     */
    clone : function()
    {
      return Keyframe( Akari.Utilities.Factory.clone( params ) );
    }
  };
};
 
/* Enum: KeyframesBindMode
 * Modes of keyframe bind behaviors.
 */
Akari.Animation.KeyframesBindMode =
{
  // hold: Hold the value of the nearest keyframe when out of range.
  hold : 0,
  
  // repeat: Repeat keyframes when out of range (last => second)
  repeat : 1,
  
  // pingPong: Ping Pong keyframes when out of range.
  pingPong : 2
};
 
/* Class: KeyframesBind
 * An animation Binding using keyframes.
 *
 * keyframes
 *   An Array containing keyframes to use, in time order.
 * mode
 *   [default] KeyframesBindMode.hold
 *   Behavior when out of range.
 */
Akari.Animation.KeyframesBind = function( params )
{
  var firstKeyframeTime = params.keyframes[ 0 ].time;
  var lastKeyframeTime = params.keyframes[ params.keyframes.length - 1 ].time;
  var duration = lastKeyframeTime - firstKeyframeTime;
  
  // Create function for out of range behavior
  var applyRangeBehavior = null;
  if ( params.mode === Akari.Animation.KeyframesBindMode.repeat )
  {
    applyRangeBehavior = function( time )
    {
      return firstKeyframeTime + ( time - firstKeyframeTime ) % ( duration );
    };
  }
  else if ( params.mode === Akari.Animation.KeyframesBindMode.pingPong )
  {
    applyRangeBehavior = function( time )
    {
      // Modulate by double the duration
      var ppTime = ( time - firstKeyframeTime ) % ( duration * 2 );
      
      if ( ppTime > duration )
      {
        return lastKeyframeTime - ppTime + duration;
      }
      else
      {
        return firstKeyframeTime + ppTime;
      }
    };
  }
  
  // Function for finding the current keyframe index
  var findCurrentIndex = function( time )
  {
    var currentIndex = 0;
    while( params.keyframes[ currentIndex + 1 ] && params.keyframes[ currentIndex + 1 ].time < time )
      currentIndex ++;
    
    return currentIndex;
  };
  
  // Return the binding function
  return function( time )
  {

    var newTime = applyRangeBehavior ? applyRangeBehavior( time ) : time;
    
    var currentIndex = findCurrentIndex( newTime );
    var currentKey = params.keyframes[ currentIndex ];
    var nextKey = params.keyframes[ currentIndex + 1 ];
    
    // Whether there is a next keyframe to interpolate to
    if ( nextKey )
    {
      var tFactor = ( newTime - currentKey.time ) / ( nextKey.time - currentKey.time );
      
      if ( currentKey.mode === Akari.Animation.KeyframeMode.affectNext )
      {

        return currentKey.interpolation( tFactor, currentKey.value, nextKey.value );
      }
      else if ( currentKey.mode === Akari.Animation.KeyframeMode.useNext )
      {

        return nextKey.interpolation( tFactor, currentKey.value, nextKey.value );
      }
      else if ( currentKey.mode === Akari.Animation.KeyframeMode.weightBlend )
      {
        var value1 = currentKey.interpolation( tFactor, currentKey.value, nextKey.value );
        var value2 = nextKey.interpolation( tFactor, currentKey.value, nextKey.value );
        
        var weight1 = currentKey.weight * ( 1 - tFactor );
        var weight2 = nextKey.weight * tFactor;

        return ( value1 * weight1 + value2 * weight2 ) / ( weight1 + weight2 );
      }
    }
    else
    {

      // When there is not a next keyframe for some reason, just return the current value
      return currentKey.value;
    }
  };
};
/* Class: WiggleKeyframes
 * A set of keyframes that make a wiggle effect.
 *
 * origin
 *   Number or Array of Numbers to wiggle upon.
 * numSteps
 *   Number of keyframes to generate.
 * startTime
 *   Time (in milliseconds) at which the wiggle starts.
 * stepTime
 *   Time (in milliseconds) each step will last for.
 * amount
 *   Strength of the effect.
 * rng
 *   [default] Akari.Utilities.Randomizer
 *   RNG to use when generating random vector.
 * interpolation
 *   [default] Interpolation.cubic.easeInOut
 *   Function used to interpolate between values.
 * returnCenter
 *   [default] false
 *   Indicated whether to return to center before every move
 */
Akari.Animation.WiggleKeyframes = function( params )
{
  var rng = params.rng || Akari.Utilities.Randomizer;

  // Private function for randomizing with base
  var randomize = function( origin )
  {
    if ( origin.hasOwnProperty("length") )
    {
      var randVector = rng.vector( origin.length );
      
      // Scale vector to fit amount constraint
      var scaledVector = Akari.Utilities.Vector.scale( randVector, params.amount / vectorLength( randVector ) );
      
      return Akari.Utilities.Vector.add( origin, scaledVector );
    }
    else
    {
      // Origin is not Array, return a simple randomization
      return origin + params.amount * ( rng.uniform() - 0.5 );
    }
  };
  
  if ( params.returnCenter )
  {
    var keyframes = [];
    for( var c = 0; c < params.numSteps; c ++ )
    {
      keyframes.push( Akari.Animation.Keyframe({ time : params.startTime + params.stepTime * c - 1, value : params.origin, interpolation : Akari.Animation.Interpolation.hold }) );
      keyframes.push( Akari.Animation.Keyframe({ time : params.startTime + params.stepTime * c, value : randomize( params.origin ), interpolation : params.interpolation || Akari.Animation.Interpolation.cubic.easeInOut }) );
    }
    
    // Repeat first for consistency
    keyframes.push( Akari.Animation.Keyframe({ time : params.startTime + params.stepTime * ( ++ c ) - 1, value : params.origin, interpolation : Akari.Animation.Interpolation.hold }) );
    
    return keyframes;
  }
  else
  {
    var keyframes = [];
    for( var c = 0; c < params.numSteps; c ++ )
    {
      keyframes.push( Akari.Animation.Keyframe({ time : params.startTime + params.stepTime * c, value : randomize( params.origin ), interpolation : params.interpolation || Akari.Animation.Interpolation.cubic.easeInOut }) );
    }
    
    // Repeat first for consistency
    keyframes.push( Akari.Animation.Keyframe({ time : params.startTime + params.stepTime * ( ++ c ), value : keyframes[ 0 ].value, interpolation : params.interpolation || Akari.Animation.Interpolation.cubic.easeInOut }) );
    
    return keyframes;
  }
};

/* Namespace: Akari.Display
 * This sort of classes are abstractions of display objects for use in production.
 */

Akari.Display = {};
 
/* Class: Layer
 * Provides functions for animating contents.
 *
 * source
 *   A DisplayObject serving as the layer source.
 * inPoint
 *   A Number, the time (in milliseconds) at which the layers enters.
 * outPoint
 *   A Number, the time (in milliseconds) at which the layers exits.
 * properties
 *   [default] {}
 *   An Object, containing values or Bindings for each AS3 property.
 * effects
 *   Array( [ Constructor effect, PlainObject params ] ). Effects should have an stackInterface that handles pipelining.
 *   stackInterface should be a Function( Layer, PlainObject params ) that incorporates the missing Layer parameter into params and calls effect Constructor.
 */
Akari.Display.Layer = function( params )
{
  // Create a private binder for properties
  var binder = Akari.Utilities.Binder({ object : params.source, properties : params.properties || {} });
  
  var layer =
  {
    source : params.source,
    inPoint : params.inPoint,
    outPoint : params.outPoint,
    
    /* Function: update
     * Updates the layer to fit the timeline.
     *
     * time
     *   A Number, the current time (in milliseconds) on the Composition's timeline.
     */
    update : function( time )
    {
      if ( time < params.inPoint || time >= params.outPoint )
      {
        this.source.visible = false;
      }
      else
      {
        // Set source visible first, so that it can be overridden by binder.
        this.source.visible = true;
        
        binder.update( time, this.getBinderScope() );
      }
    },
    
    /* Function: getBinderScope
     * Dynamically return self for use as scope in Binders.
     */
    getBinderScope : function()
    {
      return this;
    },
    
    /* Function: clone
     * Custom clone function for binder to work.
     */
    clone : function()
    {
      return Akari.Display.Layer( Akari.Utilities.Factory.clone( params ) );
    }
  };

  // effect stack support
  if ( params.effects )
  {
    for ( var i = 0; i < params.effects.length; i ++ )
    {
      layer = params.effects[ i ][ 0 ].stackInterface( layer, params.effects[ i ][ 1 ] );
    }
  }
  
  // Update Layer for a first time to prevent flashing
  layer.update( params.inPoint );
  
  return layer;
};

/* Class: DynamicSourceLayer
 * A type of layer specialized to handle dynamic layer sources.
 *
 * provider
 *   A DynamicLayerSourceProvider.
 * inPoint
 *   A Number, the time (in milliseconds) at which the layers enters.
 * outPoint
 *   A Number, the time (in milliseconds) at which the layers exits.
 * inPointTime
 *   [default] provider.startTime
 *   A Number, the time (in milliseconds) the DynamicLayerSourceProvider is at when the layers enters.
 * outPointTime
 *   [default] provider.startTime + provider.duration
 *   A Number, the time (in milliseconds) the DynamicLayerSourceProvider is at when the layers exits.
 * timeRemap
 *   [default] null
 *   A Function or null, depending on whether you need time remapping. Setting this function overrides inPointTime and outPointTime settings.
 *   The function should accept a parameter time (in milliseconds) the current time.
 * properties
 *   [default] {}
 *   An Object, containing values or Bindings for each AS3 property.
 * effects
 *   Array( [ Constructor effect, PlainObject params ] ). Effects should have an stackInterface that handles pipelining.
 *   stackInterface should be a Function( Layer, PlainObject params ) that incorporates the missing Layer parameter into params and calls effect Constructor.
 */
Akari.Display.DynamicSourceLayer = function( params )
{
  var nestedProvider = params.provider;
  var inPointTime = params.inPointTime || nestedProvider.startTime;
  var outPointTime = params.outPointTime || nestedProvider.startTime + nestedProvider.duration;
  
  // Create a Layer.
  var layer = Akari.Display.Layer(
  {
    source : nestedProvider.canvas,
    inPoint : params.inPoint,
    outPoint : params.outPoint,
    properties : params.properties
  });
  
  // Simulate inheritance by making a backup of update function.
  var baseUpdate = Akari.Utilities.Factory.clone( layer.update, layer );
  
  // Declare new update regarding nested DynamicLayerSourceProvider timeline.
  // Declare different functions according to having timeRemap or not to improve performance.
  if ( params.timeRemap )
  {
    layer.update = function( time )
    {
      baseUpdate( time );
      
      if ( this.source.visible )
        nestedProvider.update( params.timeRemap( time ) );
    };
  }
  else
  {
    layer.update = function( time )
    {
      baseUpdate( time );
      
      if ( this.source.visible )
        nestedProvider.update( inPointTime + ( time - params.inPoint ) * (outPointTime - inPointTime) / ( params.outPoint - params.inPoint) );
    };
  }
    
  /* Function: clone
   * Custom clone function for binder to work.
   */
  layer.clone = function()
  {
    return Akari.Display.DynamicSourceLayer( Akari.Utilities.Factory.clone( params ) );
  };

  // effect stack support
  if ( params.effects )
  {
    for ( var i = 0; i < params.effects.length; i ++ )
    {
      layer = params.effects[ i ][ 0 ].stackInterface( layer, params.effects[ i ][ 1 ] );
    }
  }
  
  // Update Layer for a first time to prevent flashing
  layer.update( params.inPoint );
  
  return layer;
};

/* Class: Composition
 * A DynamicLayerSourceProvider that provides functions as the framework of a scene.
 *
 * width
 *   [default] $.width
 *   A Number specifying stage width.
 * height
 *   [default] $.height
 *   A Number specifying stage height.
 * startTime
 *   [default] 0
 *   A Number, the time (in milliseconds) when the timeline starts.
 * duration
 *   [default] 60000
 *   A Number, the length (in milliseconds) of the timeline.
 * layers
 *   [default] []
 *   An Array of Layers, from top to bottom.
 * hasBoundaries
 *   [default] false
 *   Whether a mask will be put on the canvas so that elements outside become invisible.
 */
Akari.Display.Composition = function( params )
{
  var canvas = Akari.Display.Sprite();
  if ( params.hasBoundaries )
  {
    var solidMask = Akari.Display.Solid({ width : params.width || $.width, height : params.height || $.height, color : 0x0 });
    canvas.addChild( solidMask );
    canvas.mask = solidMask;
  }
  
  var layers = Akari.Utilities.Factory.collapse( params.layers || [] );
  var i = 0;
  
  for ( i = 0; i < layers.length; i ++ )
  {
    canvas.addChild( layers[ i ].source );
    layers[ i ].parent = this;
  }
  
  return
  {
    width : params.width || $.width,
    height : params.height || $.height,
    startTime : params.startTime || 0,
    duration : params.duration || 60000,
    layers : layers,
    canvas : canvas,
    
    /* Function: update
     * Updates the canvas to fit the timeline.
     *
     * time
     *   A Number, the current time (in milliseconds) on the Composition's own timeline.
     */
    update : function( time )
    {
      // Check if Composition is active, otherwise update for borderline situations.
      if ( time < startTime )
        return this.update( startTime );
      if ( time >= startTime + duration )
        return this.update( startTime + duration - 1 );

      for ( var i = layers.length; i --; )
      {

        layers[ 0 + i ].update( time );

      }

    },
    
    /* Function: clone
     * Custom clone function to ensure masking work.
     */
    clone : function()
    {
      return Akari.Display.Composition( Akari.Utilities.Factory.clone( params ) );
    }
  };
};

/* Class: MainComposition
 * Provides functions as the framework of the comment art. Only MainCompositions have ability to be presented.
 *
 * width
 *   [default] $.width
 *   A Number specifying stage width.
 * height
 *   [default] $.height
 *   A Number specifying stage height.
 * startTime
 *   [default] 0
 *   A Number, the time (in milliseconds) when the timeline starts.
 * duration
 *   [default] 60000
 *   A Number, the length (in milliseconds) of the timeline.
 * layers
 *   [default] []
 *   An Array of Layers, from top to bottom.
 * hasBoundaries
 *   [default] true
 *   Whether a mask will be put on the canvas so that elements outside become invisible.
 */
Akari.Display.MainComposition = function( params )
{
  if (!( params.hasBoundaries === false ))
  {
    params.hasBoundaries = true;
  }
  
  var composition = Akari.Display.Composition( params );
  
  // Remember when did the comp last update to maintain seekability.
  var lastUpdate = -1;
  
  // Remember the player size to maintain scalability
  var lastWidth, lastHeight;

  // Prepare the frame function, need a private handle for removing.
  var frameFunction = function()
  {

    // Check if player is running
    if ( Player.state === "playing" )
    {        
      Akari.Utilities.Timer.update();
      
      composition.update( Akari.Utilities.Timer.time );
    }
    else
    {
      // When player is not running, check last update time to ensure seekability.
      if ( lastUpdate != Player.time )
        composition.update( Player.time );
    }
    
    // Check if player size changed
    // I dislike polling but can't find a event to listen for this. Need suggestion
    if ( $.width != lastWidth || $.height != lastHeight )
    {
      maximizeInContainer();
      
      lastWidth = $.width;
      lastHeight = $.height;
    }

  };
  
  var maximizeInContainer = function()
  {
    ratio = Math.min( $.width / Akari.root.scaleX / composition.width, $.height / Akari.root.scaleY / composition.height );
    composition.canvas.scaleX = ratio;
    composition.canvas.scaleY = ratio;
    
    composition.canvas.x = ( $.width / Akari.root.scaleX - composition.width * ratio ) / 2;
    composition.canvas.y = ( $.height / Akari.root.scaleY - composition.height * ratio ) / 2;
  };
  
  // Declare new update for update time stuff
  var baseUpdate = Akari.Utilities.Factory.clone( composition.update, composition );
  
  composition.update = function( time )
  {
    lastUpdate = time;
    baseUpdate( time );
  };

  /* Function: present
   * Presents the composition immediately. Only one Composition can be presented at a time.
   */
  composition.present = function()
  {
    this.canvas.addEventListener( "enterFrame", frameFunction );
    
    Akari.root.addChild( this.canvas );
    
    frameFunction();
  };
    
  /* Function: detach
   * Detaches the composition from player.
   */
  composition.detach = function()
  {
    this.canvas.removeEventListener( "enterFrame", frameFunction );
    
    Akari.root.removeChild( this.canvas );
  };
    
  /* Function: clone
   * Custom clone function for binder to work.
   */
  composition.clone = function()
  {
    return Akari.Display.MainComposition( Akari.Utilities.Factory.clone( params ) );
  };
  
  // Return Composition
  return composition;
};

/* Static Function: getInstance
 * Read the global variable. Only avaiable after one has been presented.
 */
Akari.Display.MainComposition.getInstance = function()
{
  return Global._get("__mainComp_akari");
};

/* Class: Animation
 * A DynamicLayerSourceProvider with primitive stop motion animation support.
 *
 * frames
 *   An Array of functions with signature function( graphics ){ }.
 * frameRate
 *   [default] 12
 *   The rate at which the animation is played.
 *   Setting a rate much too high while having a complex scene can probably cause performance problems.
 */
Akari.Display.Animation = function( params )
{
  var lastFrame = 0;
  var frameRate = params.frameRate || 12;
  
  // Function for getting the current frame
  var findCurrentIndex = function( time )
  {
    return Math.floor( time * frameRate / 1000 );
  };
  
  var canvas = Akari.Display.Shape();
  
  return
  {
    startTime : 0,
    duration : params.frames.length * 1000 / frameRate,
    canvas : canvas,
    
    /* Function: update
     * Updates the canvas to fit the timeline.
     *
     * time
     *   A Number, the current time (in milliseconds) on the Animation's own timeline.
     */
    update : function( time )
    {
      // Check if an update is needed
      var currentFrame = findCurrentIndex( time );
      if ( currentFrame === lastFrame ) return;
      
      canvas.graphics.clear();
      params.frames[ currentFrame ]( canvas.graphics );
      
      lastFrame = currentFrame;
    },
    
    /* Function: clone
     * Custom clone function for canvas and such.
     */
    clone : function()
    {
      return Akari.Display.Animation( Akari.Utilities.Factory.clone( params ) );
    }
  };
};

/* Class: Sprite
 * Shortcut for AS3 Sprite.
 */
Akari.Display.Sprite = function()
{
  var sprite = $.createCanvas(
  {
    lifeTime : 810114514
  });
  
  ScriptManager.popEl( sprite );
  
  // remove 3D to make it clear by default
  sprite.transform.matrix3D = null;
  
  return sprite;
};

/* Class: Shape
 * Shortcut for AS3 Shape.
 */
Akari.Display.Shape = function()
{
  var shape = $.createShape(
  {
    lifeTime : 810114514
  });
  
  ScriptManager.popEl( shape );
  
  // remove 3D to make it clear by default
  shape.transform.matrix3D = null;
  
  return shape;
};

/* Class: TextField
 * Shortcut for AS3 TextField.
 */
Akari.Display.TextField = function(params)
{
  var txt = $.createComment("",
  {
    lifeTime : 810114514
  });
  
  ScriptManager.popEl( txt );
  
  // remove 3D to make it clear by default
  txt.transform.matrix3D = null;

  txt.text = params.text || "";
  txt.textColor  = params.color || 0xffffff;
  txt.fontsize = params.fontsize || 32;
  txt.font = params.font || "黑体"; 
  txt.filters = params.filters || null ;
  txt.x = params.x || 0 ;
  txt.y = params.y || 0 ;

  return txt;
};
/* Class: Solid
 * A solid color layer source.
 *
 * width
 *   A Number specifying solid width.
 * height
 *   A Number specifying solid height.
 * color
 *   A Number specifying solid color.
 */
Akari.Display.Solid = function( params )
{
  var shape = Akari.Display.Shape();
  
  shape.graphics.beginFill( params.color );
  shape.graphics.drawRect( 0, 0, params.width, params.height );
  shape.graphics.endFill();
  
  return shape;
};
/* Class: Anchor
 * Anchors the layer source at a specific point
 *
 * source
 *   The DisplayObject to wrap around
 * x
 *   [default] source.width / 2
 *   Anchor X.
 * y
 *   [default] source.height / 2
 *   Anchor Y.
 */
Akari.Display.Anchor = function( params )
{
  var sprite = Akari.Display.Sprite();
  
  sprite.addChild( params.source );
  params.source.x = - ( params.x || params.source.width / 2 );
  params.source.y = - ( params.y || params.source.height / 2 );
  
  return sprite;
};

/* Class: Anchor3D
 * Anchors the layer source at a specific point in 3D space
 *
 * source
 *   The DisplayObject to wrap around
 * x
 *   [default] source.width / 2
 *   Anchor X.
 * y
 *   [default] source.height / 2
 *   Anchor Y.
 * z
 *   [default] 0
 *   Anchor Z.
 */
Akari.Display.Anchor3D = function( params )
{
  var sprite = Akari.Display.Sprite();
  
  sprite.addChild( params.source );
  params.source.x = - ( params.x || params.source.width / 2 );
  params.source.y = - ( params.y || params.source.height / 2 );
  params.source.z = - ( params.z || 0 );
  
  return sprite;
};

/* Class: Checkerboard
 * A checkboard layer source.
 *
 * width
 *   A Number specifying checkboard width.
 * height
 *   A Number specifying checkboard height.
 * frequencyX
 *   Number of blocks on X axis.
 * frequencyY
 *   Number of blocks on Y axis.
 * color1
 *   A Number specifying checkboard background color.
 * color2
 *   A Number specifying checkboard foreground color.
 */
Akari.Display.Checkerboard = function( params )
{
  var shape = Akari.Display.Shape();
      shape.graphics.beginFill( params.color1 );

  shape.graphics.drawRect( 0, 0, params.width, params.height );
  shape.graphics.endFill();
  
  // Draw the foreground
  shape.graphics.beginFill( params.color2 );
  
  // Draw the horizontal snake
  var i = 0;
  for ( i = 0; i <= params.frequencyY; i ++ )
  {
    if ( i % 2 === 0 )
    {
      shape.graphics.lineTo( 0, params.height * i / params.frequencyY );
      shape.graphics.lineTo( params.width, params.height * i / params.frequencyY );
    }
    else
    {
      shape.graphics.lineTo( params.width, params.height * i / params.frequencyY );
      shape.graphics.lineTo( 0, params.height * i / params.frequencyY );
    }
  }
  if ( params.frequencyY % 2 === 0 )
  {
    shape.graphics.lineTo( params.width, 0 );
  }
  shape.graphics.lineTo( 0, 0 );
  
  // Draw the vertical snake
  shape.graphics.moveTo( 0, 0 );
  for ( i = 0; i <= params.frequencyX; i ++ )
  {
    if ( i % 2 === 0 )
    {
      shape.graphics.lineTo( params.width * i / params.frequencyX, 0 );
      shape.graphics.lineTo( params.width * i / params.frequencyX, params.height );
    }
    else
    {
      shape.graphics.lineTo( params.width * i / params.frequencyX, params.height );
      shape.graphics.lineTo( params.width * i / params.frequencyX, 0 );
    }
  }
  if ( params.frequencyX % 2 === 0 )
  {
    shape.graphics.lineTo( 0, params.height );
  }
  shape.graphics.lineTo( 0, 0 );
  
  shape.graphics.endFill();
  
  return shape;
};
/* Namespace: Akari.Display.Effects
 * This sort of classes are effects that wrap around layers. Not to be confused with filters which should be set with Binders.
 */

Akari.Display.Effects = {};

/* Class: TrackMatte
 * Use another layer as a mask.
 *
 * layer
 *   The Layer to be masked.
 * mask
 *   The mask Layer.
 */
Akari.Display.Effects.TrackMatte = function( params )
{
  // Replace original source with double canvas that contains both display objects,
  // which will be added to the Composition instead.
  var canvas = Akari.Display.Sprite();
  var layerCanvas = Akari.Display.Sprite();
  //add----------------------------------------------------------------------------------------
  params.layer.source.mask = params.mask.source;
   //add----------------------------------------------------------------------------------------
  layerCanvas.addChild( params.layer.source );
  layerCanvas.addChild( params.mask.source );
  canvas.addChild( layerCanvas );
  params.layer.source = canvas;

  layerCanvas.blendMode = "layer";
  
  // Simulate inheritance by making a backup of update function.
  var baseUpdate = Akari.Utilities.Factory.clone( params.layer.update, params.layer );
  
  params.layer.update = function( time )
  {
    baseUpdate( time );
    params.mask.update( time );

    params.mask.source.blendMode = "alpha";
    canvas.blendMode = params.layer.source.blendMode;
  };
  
  return params.layer;
};

/* Static Function: stackInterface
 * params omits layer.
 */
Akari.Display.Effects.TrackMatte.stackInterface = function( layer, params )
{
  return Akari.Display.Effects.TrackMatte( Akari.Utilities.Factory.extend( params, { layer : layer } ) );
};

/* Class: ForceMotionBlur
 * An effect dedicated to create motion blur effects which Flash lacks. Use the effect with Replicator.
 *
 * layers
 *   The Layers to use.
 * exposureTime
 *   [default] 20.8333333
 *   Exposure time (in milliseconds). Defaults to 1000/48 (double the Player frame rate).
 * shutterPhase
 *   [default] -90
 *   Shutter phase in degrees.
 */
Akari.Display.Effects.ForceMotionBlur = function( params )
{
  if ( !params.exposureTime ) params.exposureTime = 1000.0 / 48.0;
  var shutterOffset = params.exposureTime * ( params.shutterPhase || -90.0 ) / 180.0;
  
  // Use double canvas since to preserve blend mode, the return from adding must be contained by a Sprite with blendMode "layer"
  var canvas = Akari.Display.Sprite();
  var layerCanvas = Akari.Display.Sprite();
  
  // An invisible layer for preserving alpha and blend
  var original = params.layers.shift();
  
  // Add sub-layers to display tree, calculate alpha values to avoid the internal 256 thing
  var subLayers = params.layers;
  var subAlphas = [];
  var totalAlphaYet = 0;
  var i = 0;
  for ( i = 0; i < subLayers.length; i++ )
  {
    var idealTotalAlpha = Math.ceil( 256 * ( i + 1 ) / subLayers.length );
    var subAlpha = idealTotalAlpha - totalAlphaYet;
    subAlphas.push( ( subAlpha + 1 ) / 256 );
    totalAlphaYet += subAlpha;

    var addWrap = Akari.Display.Sprite();
    addWrap.alpha = subAlphas[ i ];
    addWrap.blendMode = "add";
    addWrap.addChild( subLayers[ i ].source );
    layerCanvas.addChild( addWrap );
  }

  layerCanvas.blendMode = "layer";
  canvas.addChild( layerCanvas );
  
  // Create a new layer, binding alpha and blendMode with original layer
  var layer = Akari.Display.Layer(
  {
    source : canvas,
    inPoint : original.inPoint,
    outPoint : original.outPoint
  });
  
  // Simulate inheritance by making a backup of update function.
  var baseUpdate = Akari.Utilities.Factory.clone( layer.update, layer );
  
  // Declare new update
  layer.update = function( time )
  {
    // Update original layer to get binding work
    original.update( time );
    layer.source.blendMode = original.source.blendMode;

    for ( var ir = subLayers.length - 1; ir >= 0; ir -- )
    {
      subLayers[ ir ].update( time + params.exposureTime * ir / subLayers.length + shutterOffset );
      subLayers[ ir ].source.blendMode = "layer";
    }
  };
  
  return layer;
};

/* Static Function: stackInterface
 * params omits layers.
 *
 * sampleCount
 *   [default] 6
 *   Number of samples to use.
 */
Akari.Display.Effects.ForceMotionBlur.stackInterface = function( layer, params )
{
  var layers = [];

  layers.push( layer );

  for ( var i = 0; i < params.sampleCount; i ++ )
  {
    layers.push( Akari.Utilities.Factory.clone( layer ) );
  }

  return Akari.Display.Effects.ForceMotionBlur( Akari.Utilities.Factory.extend( params, { layers : layers } ) );
};
/* Namespace: Akari.Display.Text
 * Classes for displaying vector text.
 */
Akari.Display.Text = {};

/* Enum: RangeShape
 * Shaping functions for RangeSelector.
 */
Akari.Display.Text.RangeShape =
{
  square : function( proportion )
  {
    if ( proportion < this.start + this.offset ) return 0;
    if ( proportion > this.end + this.offset ) return 0;

    return 1;
  },

  triangle : function( proportion )
  {
    if ( proportion < this.start + this.offset ) return 0;
    if ( proportion > this.end + this.offset ) return 0;

    if ( proportion < this.offset + ( this.start + this.end ) / 2 )
    {
      return ( proportion - this.offset - this.start ) * 2 / ( this.end - this.start );
    }

    return ( this.end + this.offset - proportion ) * 2 / ( this.end - this.start );
  },

  rampUp : function( proportion )
  {
    if ( proportion < this.start + this.offset ) return 0;
    if ( proportion > this.end + this.offset ) return 1;

    return ( proportion - this.offset - this.start ) / ( this.end - this.start );
  },

  rampDown : function( proportion )
  {
    if ( proportion < this.start + this.offset ) return 1;
    if ( proportion > this.end + this.offset ) return 0;

    return ( this.end + this.offset - proportion ) / ( this.end - this.start );
  }
};

/* Class: RangeSelector
 * A Selector that selects characters by their place in the string.
 *
 * basis
 *   [default] "characters"
 *   Specifies the basis of the selection. Possible values: "characters", "lines".
 * shapingFunc
 *   [default] RangeShape.square
 *   A function that maps proportion to 0 - 1 effect factor values, deciding the range's shape, hence the name.
 * properties
 *   [default] {
 *               start : 0,
 *               end : 1,
 *               offset : 0
 *             }
 *   Bindings for selector properties, units are proportion.
 */
Akari.Display.Text.RangeSelector = function( params )
{
  var props =
  {
    start : 0,
    end : 1,
    offset : 0
  };
  var propsBinder = Akari.Utilities.Binder({ object: props, properties : params.properties });

  var shapingFunc = params.shapingFunc || Akari.Display.Text.RangeShape.square;
  
  // See if we need to operate on characters
  if ( !params.basis || params.basis === "characters" )
  {
    return
    {
      select : function( time, linesContainer, callback )
      {
        propsBinder.update( time );
        
        // Keep track of current index to get the proportion
        var accumIndex = 0;
        var length = 0;
        
        // Iterate through the linesContainer a first time getting length
        for ( var lineIndex = 0; lineIndex < linesContainer.numChildren; lineIndex ++ )
        {
          length += ( linesContainer.getChildAt( lineIndex ) ).numChildren;
        }
        
        // Iterate through the linesContainer a second time operating
        for ( var lineIndex = 0; lineIndex < linesContainer.numChildren; lineIndex ++ )
        {
          var line = linesContainer.getChildAt( lineIndex );
          
          for ( var charIndex = 0; charIndex < line.numChildren; charIndex ++ )
          {
            callback( line.getChildAt( charIndex ), shapingFunc.apply( props, [ ( accumIndex + charIndex ) / length ] ) );
          }
          
          accumIndex += line.numChildren;
        }
      }
    };
  }
  else
  {
    return
    {
      select : function( time, linesContainer, callback )
      {
        propsBinder.update( time );
        
        // Iterate through the linesContainer operating
        for ( var lineIndex = 0; lineIndex < linesContainer.numChildren; lineIndex ++ )
        {
          var line = linesContainer.getChildAt( lineIndex );

          callback( line, shapingFunc.apply( props, [ lineIndex / linesContainer.numChildren ] ) );
        }
      }
    };
  }
};

/* Class: Animator
 * Used by DynamicVectorTextLayer for per-character animation.
 *
 * selector
 *   A Selector defining the effect range of this Animator.
 * bindings
 *   A set of Bindings defining behavior of characters within the effect range.
 * blendingFunc
 *   [default] function( value1, value2, effectFactor ) { return value1 + value2 * effectFactor; }
 *   Function for blending the value generated by animator with the original one.
 */
Akari.Display.Text.Animator = function( params )
{
  // An empty object for new properties for glyphs
  var props = {};
  var propsBinder = Akari.Utilities.Binder({ object : props, properties : params.bindings, overridePathCheck : true });

  var blendingFunc = params.blendingFunc || function( value1, value2, effectFactor ) { return value1 + value2 * effectFactor; };
  
  // Private function used as callback for Selector
  var selectCallback = function( object, effectFactor )
  {
    foreach( props, function( key, value )
    {
      // Check if it exists anyway, we can still use nonexistents and Links since those are processed by the Binder
      if ( object.hasOwnProperty( key ) )
      {
        // No checking here since try/catches just don't work. It's the user's responsibility now
        object[ key ] = blendingFunc( object[ key ], props[ key ], effectFactor );
      }
    });
  };
  
  return
  {
    apply : function( time, linesContainer )
    {
      propsBinder.update( time );

      params.selector.select( time, linesContainer, selectCallback );
    }
  };
};

/* Class: DynamicVectorTextLayer
 * A type of layer specialized to display basic dynamic vector text (huge sizes over 200px or exotic fonts).
 *
 * dictionary
 *   [default] null
 *   An Object containing functions with signature function( graphics ){ } for possible glyphs.
 *   Glyphs should be provided by user, be anchored at top-left and be of 200px in size.
 *   Deprecated. Use the font parameter in textProperties instead.
 * font
 *   [default] null
 *   A Xarple's vector font data object.
 *   If font is set, lineHeight and letterSpacing will be overrided by font settings if omitted.
 * textProperties
 *   [default] { horizontalAlign : "left", verticalAlign : "top", letterSpacing : 20, fixedWidth : false, fontSize : 200, lineHeight : 240, text : "" }
 *   An Object, containing values or Bindings for vector text properties: horizontalAlign, verticalAlign, fontSize, letterSpacing, lineHeight, text.
 *   If fixedWidth is true, spacing between characters will always be fontSize + letterSpacing or ( fontSize / 2 ) + letterSpacing depending on which the actual width is nearer to.
 * inPoint
 *   A Number, the time (in milliseconds) at which the layers enters.
 * outPoint
 *   A Number, the time (in milliseconds) at which the layers exits.
 * properties
 *   [default] {}
 *   An Object, containing values or Bindings for each AS3 property.
 * animators
 *   [default] []
 *   Animators for per-character animation. Using animators will cause the glyphs be re-arranged every frame due to the nature of it.
 */
Akari.Display.Text.DynamicVectorTextLayer = function( params )
{
  // Create Sprites for alignment
  var linesContainer = Akari.Display.Sprite();
  var alignmentContainer = Akari.Display.Sprite();
  alignmentContainer.addChild( linesContainer );
  
  // Create objects for binding and change detection, due to lack of property getter / setters.
  if ( params.font )
  {
    var lastTextProperties = { horizontalAlign : "left", verticalAlign : "top", letterSpacing : null, fixedWidth : false, fontSize : 200, lineHeight : null, text : "", glyphFillColor : 0xFFFFFF, glyphStrokeColor : 0xFFFFFF, glyphStrokeWidth : 0 };
    var textProperties = { horizontalAlign : "left", verticalAlign : "top", letterSpacing : null, fixedWidth : false, fontSize : 200, lineHeight : null, text : "", glyphFillColor : 0xFFFFFF, glyphStrokeColor : 0xFFFFFF, glyphStrokeWidth : 0 };
  }
  else
  {
    var lastTextProperties = { horizontalAlign : "left", verticalAlign : "top", letterSpacing : 20, fixedWidth : false, fontSize : 200, lineHeight : 240, text : "", glyphFillColor : 0xFFFFFF, glyphStrokeColor : 0xFFFFFF, glyphStrokeWidth : 0 };
    var textProperties = { horizontalAlign : "left", verticalAlign : "top", letterSpacing : 20, fixedWidth : false, fontSize : 200, lineHeight : 240, text : "", glyphFillColor : 0xFFFFFF, glyphStrokeColor : 0xFFFFFF, glyphStrokeWidth : 0 };
  }
  var textPropertiesBinder = Akari.Utilities.Binder({ object : textProperties, properties : params.textProperties || {} });
  
  var animators = params.animators || [];
  
  var layer = Akari.Display.Layer(
  {
    source : alignmentContainer,
    inPoint : params.inPoint,
    outPoint : params.outPoint,
    properties : params.properties
  });
  
  // Simulate inheritance by making a backup of update function.
  var baseUpdate = Akari.Utilities.Factory.clone( layer.update, layer );
  
  layer.update = function( time )
  {
    baseUpdate( time );
      
    // Update binder and check if anything changes
    textPropertiesBinder.update( time, layer.getBinderScope() );

    var needGlyphReset = textProperties.text != lastTextProperties.text || ( textProperties.glyphFillColor != lastTextProperties.glyphFillColor ) || ( textProperties.glyphStrokeColor != lastTextProperties.glyphStrokeColor ) || ( textProperties.glyphStrokeWidth != lastTextProperties.glyphStrokeWidth );
    var needGlyphAdjust =  needGlyphReset || ( animators.length > 0 ) ||( textProperties.letterSpacing != lastTextProperties.letterSpacing ) || ( textProperties.fontSize != lastTextProperties.fontSize );
    var needAlignmentAdjust = needGlyphAdjust || ( animators.length > 0 ) || ( textProperties.horizontalAlign != lastTextProperties.horizontalAlign ) || ( textProperties.verticalAlign != lastTextProperties.verticalAlign ) || ( textProperties.lineHeight != lastTextProperties.lineHeight );

    if ( needAlignmentAdjust ) lastTextProperties = Akari.Utilities.Factory.clone( textProperties );
      
    // Split text into lines to process
    var lines = textProperties.text.split( "\n" );

    // Reset Glyphs if needed (most expensive)
    if ( needGlyphReset )
    {
      while ( linesContainer.numChildren > 0 ) linesContainer.removeChildAt( 0 );
      
      for ( var numLine = 0; numLine < lines.length; numLine ++ )
      {
        // For each line create a new Sprite to contain glyphs
        var lineSprite = Akari.Display.Sprite();
        
        for ( var numChar = 0; numChar < lines[ numLine ].length; numChar ++ )
        {
          // Create glyphs and put them in current line. Position does not matter since it will be corrected afterwards.
          var glyphShape = Akari.Display.Shape();
          var char = lines[ numLine ].charAt( numChar );
          if ( params.font )
          {
            if ( params.font.hasOwnProperty( char ) )
            {
              glyphShape.graphics.beginFill( textProperties.glyphFillColor );
              if ( textProperties.glyphStrokeWidth > 0 )
              {
                glyphShape.graphics.lineStyle( textProperties.glyphStrokeWidth, textProperties.glyphStrokeColor );
              }
              glyphShape.graphics.drawPath( params.font[ char ].commands, params.font[ char ].paths, 'nonZero' );
              glyphShape.graphics.endFill();
            }
          }
          else
          {
            params.dictionary[ char ]( glyphShape.graphics );
          }
          lineSprite.addChild( glyphShape );
        }
        
        linesContainer.addChild( lineSprite );
      }
    }

    // Adjust glyphs if needed
    if ( needGlyphAdjust )
    {
      for ( var numLine = 0; numLine < linesContainer.numChildren; numLine ++ )
      {
        var lineSprite = linesContainer.getChildAt( numLine );
        var accumulativeX = 0;
        var lastChar = null;
        
        for ( var numChar = 0; numChar < lineSprite.numChildren; numChar ++ )
        {
          var glyph = lineSprite.getChildAt( numChar );
          var char = lines[ numLine ].charAt( numChar );

          // Reset glyph positioning, so that glyphs don't "drift away" with animators.
          glyph.transform.matrix3D = null;
          mx = glyph.transform.matrix;
          mx.identity();
          glyph.transform.matrix = mx;
          
          glyph.scaleX = glyph.scaleY = textProperties.fontSize / ( params.font ? params.font.size : 200.0 );

          if ( params.font && params.font.hasOwnProperty( char ) && params.font[ char ].kernings.hasOwnProperty( lastChar ) )
          {
            accumulativeX += params.font[ char ].kernings[ lastChar ].x * glyph.scaleX;
          }
          glyph.x = accumulativeX;
          
          if ( textProperties.fixedWidth )
          {
            var nwFactor = Math.round( glyph.width / textProperties.fontSize );
            accumulativeX += textProperties.fontSize * ( nwFactor / 2 + 0.5 ) + ( textProperties.letterSpacing || 0 );
          }
          else
          {
            if ( params.font )
            {
              accumulativeX += params.font[ char ].advanceHori * glyph.scaleX + ( textProperties.letterSpacing || 0 );
            }
            else 
            {
              accumulativeX += glyph.width + textProperties.letterSpacing;
            }
          }

          lastChar = char;
        }
      }
    }
    
    // Adjust alignment if needed
    if ( needAlignmentAdjust )
    {
      for ( var numLine = 0; numLine < linesContainer.numChildren; numLine ++ )
      {
        var lineSprite = linesContainer.getChildAt( numLine );
        
        // Set line height and alignment
        switch ( textProperties.horizontalAlign )
        {
          case "left":
            lineSprite.x = 0;
            break;
          case "right":
            lineSprite.x = - lineSprite.width;
            break;
          case "center":
            lineSprite.x = - lineSprite.width / 2;
            break;
        }
        if ( params.font )
        {
          lineSprite.y = numLine * ( textProperties.lineHeight || ( params.font.height * textProperties.fontSize / params.font.size ) );
        }
        else
        {
          lineSprite.y = numLine * textProperties.lineHeight;
        }
      }
      
      // Set vertical alignment
      switch ( textProperties.verticalAlign )
      {
        case "top":
          linesContainer.y = 0;
          break;
        case "bottom":
          linesContainer.y = - linesContainer.height;
          break;
        case "center":
          linesContainer.y = - linesContainer.height / 2;
          break;
      }
    }

    // Deal with animators if needed
    if ( animators.length > 0 )
    {
      for ( var animatorIndex = 0; animatorIndex < animators.length; animatorIndex ++ )
      {
        animators[ animatorIndex ].apply( time, linesContainer );
      }
    }
  };
    
  /* Function: clone
   * Custom clone function for binder to work.
   */
  layer.clone = function()
  {
    return Akari.Display.Text.DynamicVectorTextLayer( Akari.Utilities.Factory.clone( params ) );
  };

  // Update Layer for a first time to prevent flashing
  layer.update( params.inPoint );
  
  return layer;
};
Akari.Display.Three = {};

/* Static Class: MatrixUtil
 * Utility functions for creating matrices.
 */
Akari.Display.Three.MatrixUtil =
{
  lookAt : function( eye, target )
  {
    var matT = $.createMatrix3D([]);
    var matR = $.createMatrix3D([]);

    matT.appendTranslation( -eye[ 0 ], -eye[ 1 ], -eye[ 2 ] );

    var dX = target[ 0 ] - eye[ 0 ];
    var dY = target[ 1 ] - eye[ 1 ];
    var dZ = target[ 2 ] - eye[ 2 ];
    if ( dX !== 0 )
    {
      var yAng = Akari.Utilities.Vector.angle( [ 0, 1 ], [ dX, dZ ] ) * 180 / Math.PI;
      matR.appendRotation( yAng * ( dX < 0 ? 1 : -1 ), $.createVector3D( 0, 1, 0 ) );
      if ( dY !== 0 )
      {
        var xRot = Math.asin( dY / Math.sqrt( dX * dX + dY * dY + dZ * dZ ) ) * 180 / Math.PI;
        matR.appendRotation( xRot, $.createVector3D( 1, 0, 0 ) );
      }
    }
    else if ( dY !== 0 )
    {
      var xAng = - Akari.Utilities.Vector.angle( [ 0, 1 ], [ dY, dZ ] ) * 180 / Math.PI;
      matR.appendRotation( xAng * ( dY < 0 ? 1 : -1 ), $.createVector3D( 1, 0, 0 ) );
    }

    return [ matT, matR ];
  }
};

/* Class: ThreeContainer
 * Utility class providing sorting.
 *
 * container
 *   [default] Akari.root
 *   Optional container sprite to base relative matrix on.
 */
Akari.Display.Three.ThreeContainer = function()
{
  var sortContainer = function( doc, cont, reg )
  {
    var identity = $.createMatrix3D(
      [
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
      ]);
    var transform = doc.transform.getRelativeMatrix3D( cont ) || identity;
    var numChildren = doc.numChildren;

    var vLocal = $.toNumberVector( [] );
    var vWorld = $.toNumberVector( [] );
    var children = [];
    var childrenRef = [];
    var childObj = [];
    var childIndices = [];

    for ( var a = 0; a < numChildren; a ++ )
    {
      var c = doc.getChildAt( a );
      if ( c.visible )
      {
        childObj.push( c );
        childIndices.push( a );
      }
    }

    for ( var i = 0; i < childObj.length; i ++ )
    {
      var child = childObj[ 0 + i ];
      var childTransform = child.transform.getRelativeMatrix3D( doc ) || identity;
      var relData = this.getRelatedData( child );
      var sortPoint = childTransform.transformVector( $.createVector3D( relData.sortOffsetX, relData.sortOffsetY, relData.sortOffsetZ ) );

      vLocal.push( sortPoint.x );
      vLocal.push( sortPoint.y );
      vLocal.push( sortPoint.z );

      // Using this later for sorting
      children[ 0 + i ] = i;
      childrenRef[ 0 + i ] = i;
    }

    transform.transformVectors( vLocal, vWorld );

    // Trick sorting children with closure
    children = children.sort( function( a, b )
    {
      return vWorld[ b * 3 + 2 ] - vWorld[ a * 3 + 2 ];
    });

    for ( var k = 0; k < childObj.length; k ++ )
    {
      if ( children[ 0 + k ] !== childrenRef[ 0 + k ] )
      {
        doc.swapChildrenAt( childIndices[ 0 + childrenRef.indexOf( children[ 0 + k ] ) ], childIndices[ 0 + k ] );
        childrenRef[ childrenRef.indexOf( children[ 0 + k ] ) ] = childrenRef[ 0 + k ];
        childrenRef[ 0 + k ] = children[ 0 + k ];
      }
    }
  };

  return function( container )
  {
    var doc = Akari.Display.Sprite();
    var cont = container || Akari.root;

    // Plain object treat all DisplayObjects as the same key
    var childLookup = [];
    var relatedData = [];

    return {
      register : function( displayObject, params )
      {
        var obj = Akari.Utilities.Factory.extend(
        {
          sortOffsetX : 0,
          sortOffsetY : 0,
          sortOffsetZ : 0
        }, params );

        relatedData[ childLookup.length ] = obj;
        childLookup[ childLookup.length ] = displayObject;

        doc.addChild( displayObject );
      },
      getRelatedData : function( displayObject )
      {
        var index = childLookup.indexOf( displayObject );
        return relatedData[ index ];
      },
      setRelatedData : function( displayObject, value )
      {
        var index = childLookup.indexOf( displayObject );
        return ( relatedData[ index ] = value );
      },
      update : function()
      {

        sortContainer.apply( this, [ doc, cont, relatedData ] );

      },
      canvas : doc
    };
  };
}();

/* Class: Camera
 *
 * inPoint
 * outPoint
 * position
 *   [default] [ 0, 0, 0 ]
 * target
 *   [default] [ 0, 0, 0 ]
 * fov
 *   [default] 55
 */
Akari.Display.Three.Camera = function( params )
{
  var properties = Akari.Utilities.Factory.extend(
  {
    inPoint : 0,
    outPoint : 0,
    position : [ 0, 0, 0 ],
    target : [ 0, 0, 0 ],
    rotation : [ 0, 0, 0 ],
    fov : 55
  }, params );
  var valueHolder = {};
  var binder = Akari.Utilities.Binder({ object : valueHolder, properties : properties, overridePathCheck : true });

  var proj = clone( Akari.root.transform.perspectiveProjection );

  var xAxis = $.createVector3D( 1, 0, 0 );
  var yAxis = $.createVector3D( 0, 1, 0 );
  var zAxis = $.createVector3D( 0, 0, -1 );

  return {
    inPoint : properties.inPoint,
    outPoint : properties.outPoint,

    update : function( time )
    {
      binder.update( time );
      var matrices = Akari.Display.Three.MatrixUtil.lookAt( valueHolder.position, valueHolder.target );
      this.matrixT = matrices[ 0 ];
      this.matrixR = matrices[ 1 ];
      this.matrixR.appendRotation( -valueHolder.rotation[ 0 ], xAxis );
      this.matrixR.appendRotation( -valueHolder.rotation[ 1 ], yAxis );
      this.matrixR.appendRotation( -valueHolder.rotation[ 2 ], zAxis );

      proj.fieldOfView = valueHolder.fov;
      this.projection = proj;
    },

    clone : function()
    {
      return Akari.Display.Three.Camera( Akari.Utilities.Factory.clone( params ) );
    }
  };
};

/* Class: ThreeComposition < DynamicLayerSourceProvider
 * 
 * width
 *   [default] $.width
 *   A Number specifying viewport width.
 * height
 *   [default] $.height
 *   A Number specifying viewport height.
 * startTime
 *   [default] 0
 *   A Number, the time (in milliseconds) when the timeline starts.
 * duration
 *   [default] 60000
 *   A Number, the length (in milliseconds) of the timeline.
 * layers
 *   [default] []
 *   An Array of Layers, from top to bottom.
 * cameras
 *   [default] []
 *   An Array of Cameras.
 */
Akari.Display.Three.ThreeComposition = function( params )
{
  var canvas = Akari.Display.Sprite();

  // This will make all 2D stuff work on the resulting viewport: mask, filter, blendMode, etc.
  var layerWrap = Akari.Display.Sprite();
  var container = Akari.Display.Three.ThreeContainer( layerWrap );
  layerWrap.addChild( container.canvas );
  layerWrap.blendMode = "layer";
  canvas.addChild( layerWrap );

  var solidMask = Akari.Display.Solid({ width : params.width || $.width, height : params.height || $.height, color : 0x0 });
  canvas.addChild( solidMask );
  layerWrap.mask = solidMask;
  
  var layers = Akari.Utilities.Factory.collapse( params.layers || [] );
  var i = 0;
  
  for ( i = 0; i < layers.length; i ++ )
  {
    container.register( layers[ i ].source, layers[ i ].relatedData );
    layers[ i ].parent = this;
  }

  var cameras = params.cameras || [];
  var defaultCamera = Akari.Display.Three.Camera();

  var centerMatrix = $.createMatrix3D(
    [
      1, 0, 0, 0,
      0, 1, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1
    ]);
  centerMatrix.appendTranslation( ( params.width || $.width ) / 2, ( params.height || $.height ) / 2, 0 );
  var centerPoint = $.createVector3D( ( params.width || $.width ) / 2, ( params.height || $.height ) / 2, 0 );
  
  return
  {
    width : params.width || $.width,
    height : params.height || $.height,
    startTime : params.startTime || 0,
    duration : params.duration || 60000,
    layers : layers,
    canvas : canvas,
    
    /* Function: update
     * Updates the canvas to fit the timeline.
     *
     * time
     *   A Number, the current time (in milliseconds) on the Composition's own timeline.
     */
    update : function( time )
    {
      // Check if Composition is active, otherwise update for borderline situations.
      if ( time < startTime )
        return this.update( startTime );
      if ( time >= startTime + duration )
        return this.update( startTime + duration - 1 );

      for ( var i = layers.length; i --; )
      {

        layers[ 0 + i ].update( time );

      }

      // Using linear search to assure overlapping rules work for cameras just as with layers
      var camera = defaultCamera;
      for ( var i = cameras.length - 1; i >= 0; i -- )
      {
        if ( cameras[ i + 0 ].inPoint <= time && time < cameras[ i + 0 ].outPoint )
        {
          camera = cameras[ i + 0 ];
          break;
        }
      }

      camera.update( time );
      var mat = camera.matrixT;
      var proj = camera.projection;

      var v = camera.matrixR.transformVector( centerPoint );
      var p = proj.projectionCenter;
      p.x = v.x;
      p.y = v.y;
      proj.projectionCenter = p;
      layerWrap.transform.perspectiveProjection = proj;

      mat.append( camera.matrixR );
      mat.append( centerMatrix );
      container.canvas.transform.matrix3D = mat;

      // sort
      container.update( time );

    },
    
    /* Function: clone
     */
    clone : function()
    {
      return Akari.Display.Three.ThreeComposition( Akari.Utilities.Factory.clone( params ) );
    }
  };
};
  Global._set( "__akari", Akari );

 if(playerState == "playing")
 {
 Player.play();
 ($G._("loading")).changeT("加载时尽量不要作其他操作...\n");
}