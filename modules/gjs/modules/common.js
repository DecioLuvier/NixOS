import Gio from "gi://Gio"

export function exec(command) {
    const proc = Gio.Subprocess.new(
        ["bash", "-c", command],
        Gio.SubprocessFlags.STDOUT_PIPE
    )

    const [, stdout] = proc.communicate_utf8(null, null)

    return stdout.trim()
}

export function execAsync(command) {
    return new Promise((resolve, reject) => {
        const proc = Gio.Subprocess.new(
            ["bash", "-c", command],
            Gio.SubprocessFlags.STDOUT_PIPE
            | Gio.SubprocessFlags.STDERR_PIPE
        )

        proc.communicate_utf8_async(null, null, (proc, res) => {
            try {
                const [, stdout, stderr] =
                    proc.communicate_utf8_finish(res)

                if (proc.get_successful())
                    resolve(stdout.trim())
                else
                    reject(stderr.trim())
            } catch (e) {
                reject(e)
            }
        })
    })
}

export function createState(initial) {
    let value = initial

    const listeners = new Set()

    return {
        get() {
            return value
        },

        set(newValue) {
            if (value === newValue)
                return

            value = newValue

            for (const callback of listeners)
                callback(value)
        },

        subscribe(callback) {
            listeners.add(callback)

            return () => {
                listeners.delete(callback)
            }
        },
    }
}

export function createEffect(state, callback) {
    callback(state.get())

    return state.subscribe(callback)
}