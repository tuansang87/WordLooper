
import GoogleSignIn from 'react-native-google-sign-in'

const url = 'https://www.googleapis.com/drive/v3'
const uploadUrl = 'https://www.googleapis.com/upload/drive/v3'

const boundaryString = 'foo_bar_baz' // can be anything unique, needed for multipart upload https://developers.google.com/drive/v3/web/multipart-upload

let apiToken = null


export const configureGoogleSignIn = async () => GoogleSignIn.configure({
    // https://developers.google.com/identity/protocols/googlescopes
  clientID: '665124887696-7rsi9dd3nuje7eboqc867rs5i6161cao.apps.googleusercontent.com',
  serverClientID: 'com.googleusercontent.apps.665124887696-7rsi9dd3nuje7eboqc867rs5i6161cao',
  scopes: [
    // 'https://www.googleapis.com/auth/drive',
        'https://www.googleapis.com/auth/drive.appdata',
        'https://www.googleapis.com/auth/drive.file'],
  shouldFetchBasicProfile: true,
})

export function setApiToken(token) {
  apiToken = token
}

function parseAndHandleErrors(response) {
  if (response.ok) {
    return response.json()
  }
  return response.json()
    .then((error) => {
      throw new Error(JSON.stringify(error))
    })
}

function configureGetOptions() {
  const headers = new Headers()
  headers.append('Authorization', `Bearer ${apiToken}`)
  return {
    method: 'GET',
    headers,
  }
}

function configurePostOptions(bodyLength, isUpdate = false) {
  const headers = new Headers()
  headers.append('Authorization', `Bearer ${apiToken}`)
  headers.append('Content-Type', `multipart/related; boundary=${boundaryString}`)
  headers.append('Content-Length', bodyLength)
  return {
    method: isUpdate ? 'PATCH' : 'POST',
    headers,
  }
}

function createMultipartBody(body, isUpdate = false) {
  // https://developers.google.com/drive/v3/web/multipart-upload defines the structure
  const metaData = {
    name: 'data.json',
    description: 'Backup data for my app',
    mimeType: 'application/json',
  }
  // if it already exists, specifying parents again throws an error
  if (!isUpdate) metaData.parents = ['appDataFolder']

  // request body
  const multipartBody = `\r\n--${boundaryString}\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n`
  + `${JSON.stringify(metaData)}\r\n`
  + `--${boundaryString}\r\nContent-Type: application/json\r\n\r\n`
  + `${JSON.stringify(body)}\r\n`
  + `--${boundaryString}--`

  return multipartBody
}

// uploads a file with its contents and its meta data (name, description, type, location)
export function uploadFile(content, existingFileId) {
  const body = createMultipartBody(content, !!existingFileId)
  const options = configurePostOptions(body.length, !!existingFileId)
  return fetch(`${uploadUrl}/files${existingFileId ? `/${existingFileId}` : ''}?uploadType=multipart`, {
    ...options,
    body,
  })
    .then(parseAndHandleErrors)
}

// Looks for files with the specified file name in your app Data folder only (appDataFolder is a magic keyword)
function queryParams() {
  return encodeURIComponent("name = 'data.json' and 'appDataFolder' in parents")
}

// returns the files meta data only. the id can then be used to download the file
export function getFile() {
  const qParams = queryParams()
  const options = configureGetOptions()
  return fetch(`${url}/files?q=${qParams}&spaces=appDataFolder`, options)
    .then(parseAndHandleErrors)
    .then((body) => {
      if (body && body.files && body.files.length > 0) return body.files[0]
      return null
    })
}

// download the file contents given the id
export function downloadFile(existingFileId) {
  const options = configureGetOptions()
  if (!existingFileId) throw new Error('Didn\'t provide a valid file id.')
  return fetch(`${url}/files/${existingFileId}?alt=media`, options)
    .then(parseAndHandleErrors)
}





//////////////////////////////////
// Downloading in a redux-thunk //
//////////////////////////////////
export const dispatchGoogleDrive = apiToken => (dispatch) => {
  dispatch({ type: ActionNames.dataRestoreStart })
  setApiToken(apiToken)
  return getWorkoutFile()
    .then((file) => {
      if (file) {
        return downloadFile(file.id)
      }
      throw new Error('No existing backup file found.')
    })
    .then((data) => {
      dispatch({
        type: ActionNames.dataRestoreFinished,
        payload: data,
      })
    })
    .catch(err => dispatch({ type: ActionNames.dataRestoreError, payload: err }))
}

