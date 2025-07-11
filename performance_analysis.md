# Performance Analysis and Optimization Report

## Project Overview
This Garry's Mod addon implements a realistic passenger flow system for metro/subway stations. It features:
- Dynamic passenger counts based on time and day of week
- In-game HUD showing time, rush hour status, and metro status
- Client-server architecture with time checks every 10 seconds

## Critical Performance Bottlenecks Identified

### 1. Client-Side Performance Issues (`cl_passcale_sys.lua`)

#### **CRITICAL: HUDPaint Hook Running Every Frame**
- **Issue**: The HUDPaint hook executes every frame (potentially 60+ FPS)
- **Impact**: Severe performance degradation on clients
- **Current operations per frame**:
  - Multiple `os.time()` calls
  - Multiple `os.date()` calls  
  - String parsing with `string.Explode()`
  - Day of week calculations
  - Rush hour logic evaluation

#### **Logic Error in Day Detection**
```lua
if not os.date("%a", os.time()) == "Sat" or os.date("%a", os.time()) == "Sun" then
```
- **Issue**: Operator precedence makes this always evaluate to true
- **Should be**: `if not (os.date("%a", os.time()) == "Sat" or os.date("%a", os.time()) == "Sun") then`

#### **Redundant Function Calls**
- `dayToMinuts()` called multiple times per frame
- `os.time()` and `os.date()` called repeatedly with same parameters

### 2. Server-Side Performance Issues (`sv_passcale_sys.lua`)

#### **Day Type Calculation Bug**
```lua
local vix = os.date("%a", os.time()) == "Sat" or os.date("%a", os.time()) == "Sun"
```
- **Issue**: Calculated only once when script loads, never updates
- **Impact**: Wrong passenger scaling when day changes at midnight

#### **Inefficient Time Checking**
- Fixed 10-second intervals regardless of time sensitivity
- Could use variable intervals based on time proximity to rush hours

## Optimization Recommendations

### Client-Side Optimizations

#### 1. **Move Expensive Operations Out of HUDPaint**
- Cache time calculations in a timer
- Update display strings only when needed
- Reduce HUDPaint to simple drawing operations

#### 2. **Implement Caching System**
- Cache current time state
- Cache formatted strings
- Cache rush hour status

#### 3. **Use Event-Based Updates**
- Timer-based updates instead of per-frame calculations
- Network message updates from server

### Server-Side Optimizations

#### 1. **Fix Day Type Calculation**
- Move day calculation into the check function
- Properly handle day transitions

#### 2. **Implement Smart Timer Intervals**
- More frequent checks near rush hour transitions
- Less frequent checks during stable periods

#### 3. **Add Caching and Memoization**
- Cache time calculations
- Avoid redundant console command calls

## Bundle Size Considerations

### Current Bundle Analysis
- **Total Size**: ~6KB (very lightweight)
- **Client**: 2.5KB (65 lines)
- **Server**: 3.4KB (86 lines)

### Optimization Impact
- Code optimizations will likely increase size slightly but dramatically improve performance
- Trade-off is worthwhile given performance gains

## Implementation Priority

### High Priority (Immediate)
1. Fix client-side HUDPaint performance issue
2. Fix day type calculation bug
3. Fix logic error in day detection

### Medium Priority 
1. Implement caching system
2. Add smart timer intervals
3. Optimize string operations

### Low Priority
1. Code cleanup and documentation
2. Additional error handling
3. Configuration options

## Estimated Performance Improvements

### Client-Side
- **Frame rate impact**: 95% reduction in HUDPaint overhead
- **CPU usage**: 90% reduction in time-related calculations
- **Memory**: Minimal impact with caching

### Server-Side  
- **Timer efficiency**: 30-50% reduction in unnecessary checks
- **Accuracy**: 100% fix for day transition bugs
- **Resource usage**: 20% reduction in console command calls

## Next Steps

1. Implement optimized client-side code with caching
2. Fix server-side day calculation and implement smart timers
3. Test performance improvements in GMod environment
4. Monitor for any edge cases or regressions